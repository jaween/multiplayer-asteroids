import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:multiplayer_asteroids_client_core/src/debug_info.dart';
import 'package:multiplayer_asteroids_common/common.dart';
import 'package:tuple/tuple.dart';

typedef OnConnectionStateChanged = void Function(bool connected);
typedef OnWorldStateUpdated = void Function(WorldState worldState);
typedef OnDebugInfoUpdated = void Function(DebugInfo debugInfo);

class GameClient {
  final String _host;
  final int _port;
  final CommsClient _commsClient;
  Socket _socket;

  OnConnectionStateChanged _onConnectionStateChanged;
  OnWorldStateUpdated _onWorldStateUpdated;
  OnDebugInfoUpdated _onDebugInfoUpdated;

  ConnectMessage _connectMessage;
  final _debugInfo = DebugInfo();

  Timer _tickTimer;
  int _clientSideTick;
  Map<int, WorldState> _worldStates = {};
  WorldState _predictedWorldState;
  Set<String> _inputState = {};
  Map<int, Set<String>> _pastInputStates = {};
  Map<int, DateTime> _ticksAwaitingAck = {};
  double _roundTripTimeMs = 0;
  Set<int> _worldStatesToAck = {};

  bool showStats = true;
  bool showAuthState = false;
  bool useWorldInterpolation = true;
  bool useInputPrediction = true;

  GameClient(this._host, this._port, this._commsClient);

  void start({
    @required OnConnectionStateChanged onConnectionStateChanged,
    @required OnWorldStateUpdated onWorldStateUpdated,
    OnDebugInfoUpdated onDebugInfoUpdated,
  }) {
    _onConnectionStateChanged = onConnectionStateChanged;
    _onWorldStateUpdated = onWorldStateUpdated;
    _onDebugInfoUpdated = onDebugInfoUpdated;
    _commsClient.start(_host, _port, _onConnected);
  }

  void dispose() {
    _commsClient?.close();
    _tickTimer?.cancel();
  }

  void _onUpdate(int tick) {
    _sendInput(tick);

    var predicted = _worldStates.values.last;
    var interpolated = _worldStates.values.last;

    if (useInputPrediction) {
      predicted = _inputPrediction(tick);
    }

    if (useWorldInterpolation) {
      interpolated = _worldInterpolation(tick);
    }

    final worldState = interpolated?.rebuild((b) {
          b..players.replace(predicted.players);
        }) ??
        predicted;
    _onWorldStateUpdated(worldState);
  }

  WorldState _inputPrediction(int tick) {
    final gameLoop = GameLoop.fromWorldState(_predictedWorldState);
    final playerId = _connectMessage.playerId;
    var player = _predictedWorldState.players[playerId];
    player = gameLoop.updatePlayer(player, _inputState);
    _predictedWorldState = _predictedWorldState.rebuild((b) {
      final newPlayers = _predictedWorldState.players.toMap();
      newPlayers[playerId] = player;
      b..players.replace(newPlayers);
    });
    return _predictedWorldState;
  }

  WorldState _worldInterpolation(int tick) {
    final timeInPastToSimulateMs = 100;
    final ticksInPastToSimulate =
        (timeInPastToSimulateMs / _connectMessage.serverStateUpdateMs).ceil();
    final tickToSimulate = tick - ticksInPastToSimulate;
    final interpolationTicks = _findTicksToInterpolate(tick, tickToSimulate);
    if (interpolationTicks == null) {
      return null;
    }

    // Interpolate between two states
    final fromTick = interpolationTicks.item1;
    final toTick = interpolationTicks.item2;
    final fromState = _worldStates[fromTick];
    final toState = _worldStates[toTick];
    final ratio = fromTick == toTick
        ? 0.0
        : (tickToSimulate - fromTick) / (toTick - fromTick);
    return _interpolate(fromState, toState, ratio);
  }

  Tuple2<int, int> _findTicksToInterpolate(int tick, int tickToSimulate) {
    if (_worldStates.isEmpty) {
      return null;
    }

    final tickRange = (_connectMessage.serverStatePublishMs /
            _connectMessage.serverStateUpdateMs)
        .floor();
    final lowerBoundary = tickToSimulate - tickRange;
    final upperBoundary = tickToSimulate + tickRange * 2;

    // First authoratative world state on or before the tick to simulate
    int sourceTick = _worldStates.keys.lastWhere(
      (tick) => tick >= lowerBoundary && tick <= tickToSimulate,
      orElse: () => null,
    );

    // First authoratative world state after the tick to simulate
    int destTick = _worldStates.keys.firstWhere(
      (tick) => tick > tickToSimulate && tick <= upperBoundary,
      orElse: () => null,
    );

    // We actually have the world state we wanted to simulate
    if (sourceTick == tickToSimulate) {
      destTick = sourceTick;
    }

    if (sourceTick == null || destTick == null) {
      final ticksAhead = tick - _worldStates.keys.last;
      print(
          "Interpolotion failed: Client is ${ticksAhead} ticks ahead of server");
      return null;
    }

    return Tuple2(sourceTick, destTick);
  }

  WorldState _interpolate(WorldState from, WorldState to, double ratio) {
    return from.rebuild((b) {
      for (var i = 0; i < b.asteroids.length; i++) {
        b.asteroids[i] = b.asteroids[i].rebuild((b) {
          b.x = b.x + (to.asteroids[i].x - b.x) * ratio;
          b.y = b.y + (to.asteroids[i].y - b.y) * ratio;
        });
      }
    });
  }

  void _sendInput(int tick) {
    // Send the message for a future tick
    final rttInTicks =
        (_roundTripTimeMs / _connectMessage.serverStateUpdateMs).ceil();
    final ticksInTheFuture = rttInTicks + 25;
    final futureTick = tick + ticksInTheFuture;

    final message = UserCommandMessage((b) => b
      ..tick = futureTick
      ..worldStateAcks = BuiltSet<int>.from(_worldStatesToAck).toBuilder()
      ..userCommand = UserCommand((b) {
        b..commands = BuiltSet<String>.from(_inputState).toBuilder();
      }).toBuilder());
    _ticksAwaitingAck[futureTick] = DateTime.now();
    _send(message);
    _pastInputStates[futureTick] = Set<String>.from(_inputState);
  }

  void _onConnected(Socket socket) {
    print("Connected");
    _socket = socket;
    socket.listen(_onMessage);
  }

  void _send(Message message) {
    final json = jsonEncode(messageSerializers.serialize(message));
    _socket.send(Uint8List.fromList(json.codeUnits));
  }

  void _onMessage(dynamic data) {
    if (data is Uint8List) {
      final json = String.fromCharCodes(data);
      final message = Message.fromJson(json);
      if (message is ConnectMessage) {
        _onConnectMessage(message);
      } else if (message is WorldStateMessage) {
        _onWorldStateMessage(message);
      } else if (message is AckMessage) {
        _onAckMessage(message);
      }
    } else {
      print("Unknown data on socket $data");
    }
  }

  void _onConnectMessage(ConnectMessage message) {
    _connectMessage = message;
    _clientSideTick = message.serverTick;
    print("Received connect message $_connectMessage");

    _onConnectionStateChanged(true);

    _debugInfo.connectMessage = _connectMessage;
    _onDebugInfoUpdated(_debugInfo);

    // Begins locally updating the world state at a regular interval
    int lastTimerTick = 0;
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(
        Duration(milliseconds: _connectMessage.serverStateUpdateMs), (timer) {
      // Update game state
      while (lastTimerTick < timer.tick) {
        lastTimerTick++;
        _onUpdate(_clientSideTick);
        _clientSideTick++;
      }

      // Debug info
      final latestTick = _worldStates.keys.last;
      _debugInfo.interpolationDelayMs =
          (latestTick - _clientSideTick) * _connectMessage.serverStateUpdateMs;
      if (_onDebugInfoUpdated != null) {
        _onDebugInfoUpdated(_debugInfo);
      }
    });
  }

  void _onWorldStateMessage(WorldStateMessage message) {
    _worldStates[message.serverTick] = message.worldState;
    _worldStates.removeWhere((key, value) => key < message.serverTick - 50);

    // Replays past input events
    _predictedWorldState = message.worldState;
    final playerId = _connectMessage.playerId;
    Player player = message.worldState.players[playerId];

    // It's possible that the player is not available just after connecting
    if (player == null) {
      return;
    }

    // Performs the actual replay of input events
    final gameLoop = GameLoop.fromWorldState(message.worldState);
    _pastInputStates.values.forEach((commands) {
      commands.forEach((command) {
        player = gameLoop.updatePlayer(player, commands);
      });
    });
    _predictedWorldState = gameLoop.worldState;
    _pastInputStates.clear();

    // Need to acknowledge this world state in the next user command
    _worldStatesToAck.add(message.serverTick);

    _debugInfo.authWorldState = message.worldState;
    if (_onDebugInfoUpdated != null) {
      _onDebugInfoUpdated(_debugInfo);
    }
  }

  void _onAckMessage(AckMessage message) {
    final receiveTime = DateTime.now();
    var roundTripSum = Duration(milliseconds: 0);

    var count = 0;
    for (var i = 0; i < message.sequenceNums.length; i++) {
      final seq = message.sequenceNums[i];
      if (!_ticksAwaitingAck.containsKey(seq)) {
        continue;
      }

      final sendTime = _ticksAwaitingAck[seq];
      final holdTime = Duration(microseconds: message.holdingTimeMicros[i]);
      roundTripSum += receiveTime.difference(sendTime) - holdTime;
      count++;
    }

    if (count == 0) {
      return;
    }
    _roundTripTimeMs = roundTripSum.inMilliseconds / count;
    _debugInfo.rttMs = _roundTripTimeMs;
    _onDebugInfoUpdated(_debugInfo);
  }

  void input(bool down, String action) =>
      down ? _inputState.add(action) : _inputState.remove(action);
}
