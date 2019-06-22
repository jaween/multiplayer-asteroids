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

  int _serverTick = 0;

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
      ..serverTick = _serverTick
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
    if (data is Uint8List) {
      final json = String.fromCharCodes(data);
      final message = Message.fromJson(json);
      if (message is UserCommandMessage) {
        _onUserCommandMessage(clientInfo, message);
      }
    } else {
      print("Unknown data received $data");
    }
  }

  void _onUserCommandMessage(
    ClientInfo clientInfo,
    UserCommandMessage message,
  ) {
    // TODO
  }

  void _updateState() {
    int lastUpdateTick = 0;
    Timer.periodic(_updateRate, (timer) {
      while (lastUpdateTick < timer.tick) {
        lastUpdateTick++;
        _gameLoop.update();
        _serverTick++;
      }
    });
  }

  void _publishState() {
    Timer.periodic(_publishRate, (_) {
      _clientSockets.forEach((client, socket) {
        _send(
          socket,
          WorldStateMessage(
            (b) => b
              ..serverTick = _serverTick
              ..worldState = _gameLoop.worldState.toBuilder(),
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
