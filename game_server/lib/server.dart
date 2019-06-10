import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_game_server/game_loop.dart';

class Client {
  final InternetAddress address;
  final int port;
  DateTime lastSeen;

  Client(this.address, this.port);
}

class Server {
  RawDatagramSocket _socket;
  final _clients = <String, Client>{};
  final _gameLoop = GameLoop();

  Server() {
    _listen();
    _updateState();
    _removeOldClients();
  }

  void _listen() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4444);
    print("Starting server on ${_socket.address.address}:${_socket.port}");
    _socket.listen((RawSocketEvent e) {
      final datagram = _socket.receive();
      if (datagram != null) {
        final message = String.fromCharCodes(datagram.data).trim();
        print("From ${datagram.address.address}:${datagram.port} '$message'");
        final clientAddressPort =
            "${datagram.address.address}:${datagram.port}";

        if (_clients.containsKey(clientAddressPort)) {
          _clients[clientAddressPort].lastSeen = DateTime.now();
        } else {
          _clients[clientAddressPort] = Client(datagram.address, datagram.port)
            ..lastSeen = DateTime.now();
          _gameLoop.addPlayer(clientAddressPort);
        }
      }
    });
  }

  void _updateState() {
    Timer.periodic(Duration(milliseconds: 16), (_) {
      _gameLoop.update();
      _clients.values.forEach((client) {
        final message = jsonEncode(serializers.serialize(_gameLoop.gameState));
        _socket.send(message.codeUnits, client.address, client.port);
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
