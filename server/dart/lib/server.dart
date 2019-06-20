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

  Server() {
    _listen();
    _updateState();
    _removeOldClients();
  }

  void _listen() async {
    final port = int.parse(Platform.environment['PORT']) ?? 8081;
    final commsServer = CommsServerJs();
    commsServer.start(port, _onConnection);
    print("Starting server on ${port}");
  }

  void _onConnection(Socket socket, ClientInfo clientInfo) {
    final clientAddressPort = "${clientInfo.address}:${clientInfo.port}";
    print("Client connected $clientAddressPort");

    _clientSockets[clientAddressPort] = socket;

    socket.listen((data) {
      final messageString = String.fromCharCodes(data);
      print("From $clientAddressPort '$messageString'");

      if (_clients.containsKey(clientAddressPort)) {
        _clients[clientAddressPort].lastSeen = DateTime.now();
      } else {
        _clients[clientAddressPort] =
            Client(clientInfo.address, clientInfo.port)
              ..lastSeen = DateTime.now();
        _gameLoop.addPlayer(clientAddressPort);
      }
    });
  }

  void _updateState() {
    Timer.periodic(Duration(milliseconds: 16), (_) {
      _gameLoop.update();
      _clientSockets.forEach((client, socket) {
        final message = jsonEncode(serializers.serialize(_gameLoop.gameState));
        socket.send(Uint8List.fromList(message.codeUnits));
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
}
