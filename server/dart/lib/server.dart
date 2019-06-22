import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_server/comms/comms_server_js.dart';
import 'package:multiplayer_asteroids_server/game_loop.dart';
import 'package:node_io/node_io.dart';

class Client {
  final String address;
  final int port;
  DateTime lastSeen;

  Client(this.address, this.port);
}

class Server {
  final _clients = <String, Client>{};
  final _clientSockets = <String, Socket>{};
  final _gameLoop = GameLoop();

  final _updateRate = const Duration(milliseconds: 16);
  final _publishRate = const Duration(milliseconds: 100);

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
    final playerId = _clientSockets.length;
    final clientAddressPort = "${clientInfo.address}:${clientInfo.port}";
    print("Client connected $clientAddressPort");

    final connectMessage = ConnectMessage((b) => b
      ..serverTick = 0
      ..serverStateUpdateMs = _updateRate.inMilliseconds
      ..serverStatePublishMs = _publishRate.inMilliseconds
      ..playerId = playerId);
    _send(socket, connectMessage);

    _clientSockets[clientAddressPort] = socket;

    socket.listen((data) => _onMessage(clientAddressPort, clientInfo, data));
  }

  void _onMessage(
    String clientAddressPort,
    ClientInfo clientInfo,
    dynamic data,
  ) {
    final messageString = String.fromCharCodes(data);
    if (_clients.containsKey(clientAddressPort)) {
      _clients[clientAddressPort].lastSeen = DateTime.now();
    } else {
      _clients[clientAddressPort] = Client(clientInfo.address, clientInfo.port)
        ..lastSeen = DateTime.now();
      _gameLoop.addPlayer(clientAddressPort);
    }
  }

  void _updateState() {
    int lastUpdateTick = 0;
    Timer.periodic(_updateRate, (timer) {
      while (lastUpdateTick < timer.tick) {
        _gameLoop.update();
        lastUpdateTick++;
      }
    });
  }

  void _publishState() {
    Timer.periodic(_publishRate, (_) {
      _clientSockets.forEach((client, socket) {
        _send(
          socket,
          WorldStateMessage(
            (b) => b..worldState = _gameLoop.worldState.toBuilder(),
          ),
        );
      });
    });
  }

  void _removeOldClients() {
    Timer.periodic(Duration(seconds: 8), (_) {
      final clientsToRemove = _clients.entries
          .where((entry) =>
              DateTime.now().difference(entry.value.lastSeen).inSeconds > 8)
          .map((entry) => entry.key)
          .toList(growable: false);
      if (clientsToRemove.length > 0) {
        print("Dropping clients: $clientsToRemove");
        clientsToRemove.forEach((client) {
          _clients.remove(client);
          _gameLoop.removePlayer(client);
        });
      }
    });
  }

  void _send(Socket socket, Message message) {
    final json = jsonEncode(messageSerializers.serialize(message));
    socket.send(Uint8List.fromList(json.codeUnits));
  }
}
