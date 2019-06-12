import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_game_server/game_loop.dart';
import 'package:multiplayer_asteroids_game_server/udp/udp.dart';
import 'package:multiplayer_asteroids_game_server/udp/udp_socket.dart';

class Client {
  final String address;
  final int port;
  DateTime lastSeen;

  Client(this.address, this.port);
}

class Server {
  final _clients = <String, Client>{};
  final _gameLoop = GameLoop();
  final _udpSocket = UdpSocket();

  Server() {
    _listen();
    _updateState();
    _removeOldClients();
  }

  void _listen() async {
    _udpSocket.listen(
      4444,
      onListening: (String address, int port) {
        print("Starting server on ${address}:${port}");
      },
      onMessage: (Uint8List message, RInfo rinfo) {
        final messageString = String.fromCharCodes(message);
        print("From ${rinfo.address}:${rinfo.port} '$messageString'");
        final clientAddressPort =
            "${rinfo.address}:${rinfo.port}";

        if (_clients.containsKey(clientAddressPort)) {
          _clients[clientAddressPort].lastSeen = DateTime.now();
        } else {
          _clients[clientAddressPort] = Client(rinfo.address, rinfo.port)
            ..lastSeen = DateTime.now();
          _gameLoop.addPlayer(clientAddressPort);
        }

      },
      onError: (err) {
        print("Error $err");
      }
    );
  }

  void _updateState() {
    Timer.periodic(Duration(milliseconds: 16), (_) {
      _gameLoop.update();
      _clients.values.forEach((client) {
        final message = jsonEncode(serializers.serialize(_gameLoop.gameState));
        _udpSocket.send(Uint8List.fromList(message.codeUnits), client.address, client.port);
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
