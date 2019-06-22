import 'dart:async';
import 'dart:typed_data';

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

  OnConnectionStateChanged _onConnectionStateChanged;
  OnWorldStateUpdated _onWorldStateUpdated;
  OnDebugInfoUpdated _onDebugInfoUpdated;

  ConnectMessage _connectMessage;
  final _debugInfo = DebugInfo();

  Timer _tickTimer;
  int _clientSideTick;
  Map<int, WorldState> _worldStates = {};

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
    _worldInterpolation(tick);
  }

  void _worldInterpolation(int tick) {
    final timeInPastToSimulateMs = 100;
    final ticksInPastToSimulate =
        (timeInPastToSimulateMs / _connectMessage.serverStateUpdateMs).ceil();
    final tickToSimulate = tick - ticksInPastToSimulate;
    final interpolationTicks = _findTicksToInterpolate(tick, tickToSimulate);
    if (interpolationTicks == null) {
      return;
    }

    // Interpolate between two states
    final fromTick = interpolationTicks.item1;
    final toTick = interpolationTicks.item2;
    final fromState = _worldStates[fromTick];
    final toState = _worldStates[toTick];
    final ratio = fromTick == toTick
        ? 0.0
        : (tickToSimulate - fromTick) / (toTick - fromTick);
    final interpolatedWorldState = _interpolate(fromState, toState, ratio);
    _onWorldStateUpdated(interpolatedWorldState);
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

  void _onConnected(Socket socket) {
    print("Connected");
    socket.listen(_onMessage);
  }

  void _send(Socket socket, String message) {
    final request = Request((b) => b..type = message);
    final json = serializers.serialize(request).toString().codeUnits;
    socket.send(json);
  }

  void _onMessage(dynamic data) {
    if (data is Uint8List) {
      final json = String.fromCharCodes(data);
      final message = Message.fromJson(json);
      if (message is ConnectMessage) {
        _onConnectMessage(message);
      } else if (message is WorldStateMessage) {
        _onWorldStateMessage(message);
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
  }
}
