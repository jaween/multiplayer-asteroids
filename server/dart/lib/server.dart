import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_server/comms/comms_server_js.dart';
import 'package:node_io/node_io.dart';

class Client {
  final int playerId;
  final ClientInfo clientInfo;
  final Socket socket;

  Client(this.playerId, this.clientInfo, this.socket);
}

class Server {
  final _gameLoop = GameLoop();
  int _serverTick = 0;

  final _updateRate = const Duration(milliseconds: 16);
  final _publishRate = const Duration(milliseconds: 100);

  final _clients = <Client>[];
  final _userCommands = <int, Map<int, Set<String>>>{};
  final _ticksAwaitingPlayerAck = <int, Set<int>>{};
  final _ticksToAck = <int, Map<int, DateTime>>{};

  Server() {
    _listen();
    _updateState();
    _publishState();
    _removeOldClients();
  }

  void _listen() async {
    final envPort = Platform.environment['PORT'];
    final port = envPort == null ? 8081 : int.parse(envPort);
    final commsServer = CommsServerJs();
    commsServer.start(port, _onConnection);
    print("Starting server on ${port}");
  }

  void _onConnection(Socket socket, ClientInfo clientInfo) {
    print("Client connected ${clientInfo.address}:${clientInfo.port}");
    final playerId = _clients.length;
    final client = Client(playerId, clientInfo, socket);

    _gameLoop.addPlayer(playerId);
    _clients.add(client);
    _ticksAwaitingPlayerAck[playerId] = {};
    _ticksToAck[playerId] = {};

    final connectMessage = ConnectMessage((b) => b
      ..serverTick = _serverTick
      ..serverStateUpdateMs = _updateRate.inMilliseconds
      ..serverStatePublishMs = _publishRate.inMilliseconds
      ..playerId = playerId);
    _send(socket, connectMessage);

    socket.listen((data) => _onMessage(client, data));
  }

  void _onMessage(Client client, dynamic data) {
    final receiveTime = DateTime.now();

    if (data is Uint8List) {
      final json = String.fromCharCodes(data);
      final message = Message.fromJson(json);

      _ticksToAck[client.playerId][message.tick] = receiveTime;

      if (message is UserCommandMessage) {
        _onUserCommandMessage(client, message, receiveTime);
      }
    } else {
      print("Unknown data received $data");
    }
  }

  void _onUserCommandMessage(
    Client client,
    UserCommandMessage message,
    DateTime receiveTime,
  ) {
    int ticksAhead = message.tick - _serverTick;
    if (ticksAhead.isNegative) {
      print("${DateTime.now()} late by ${ticksAhead.abs()} ticks");
    } else {
      _userCommands.putIfAbsent(message.tick, () => <int, Set<String>>{});
      _userCommands[message.tick][client.playerId] =
          message.userCommand.commands.toSet();
    }
  }

  void _updateState() {
    int lastUpdateTick = 0;
    Timer.periodic(_updateRate, (timer) {
      while (lastUpdateTick < timer.tick) {
        lastUpdateTick++;
        final commands = _userCommands[_serverTick] ?? {};
        _gameLoop.update(commands);
        _serverTick++;
      }
    });
  }

  void _publishState() {
    Timer.periodic(_publishRate, (_) {
      final message = WorldStateMessage(
        (b) => b
          ..serverTick = _serverTick
          ..worldState = _gameLoop.worldState.toBuilder(),
      );
      _clients.forEach((client) {
        _send(
          client.socket,
          message,
        );
        _ticksAwaitingPlayerAck[client.playerId].add(_serverTick);

        // TODO: Piggyback on world state message
        _send(client.socket, _buildAcksForPlayer(client.playerId));
      });
    });
  }

  AckMessage _buildAcksForPlayer(int playerId) {
    final ticksToAck = _ticksToAck[playerId];
    final message = AckMessage(
      (b) => b
        ..sequenceNums = ListBuilder(ticksToAck.keys)
        ..holdingTimeMicros = ListBuilder(
          ticksToAck.values.map((receiveTime) =>
              DateTime.now().difference(receiveTime).inMicroseconds),
        ),
    );
    _ticksToAck[playerId].clear();
    return message;
  }

  void _removeOldClients() {
    // Timer.periodic(Duration(seconds: 8), (_) {
    //   final clientsToRemove = _clients.entries
    //       .where((entry) =>
    //           DateTime.now().difference(entry.value.lastSeen).inSeconds > 8)
    //       .map((entry) => entry.key)
    //       .toList(growable: false);
    //   if (clientsToRemove.length > 0) {
    //     print("Dropping clients: $clientsToRemove");
    //     clientsToRemove.forEach((client) {
    //       _clients.remove(client);
    //       //_gameLoop.removePlayer(client);
    //     });
    //   }
    // });
  }

  void _send(Socket socket, Message message) {
    final json = jsonEncode(messageSerializers.serialize(message));
    socket.send(Uint8List.fromList(json.codeUnits));
  }
}
