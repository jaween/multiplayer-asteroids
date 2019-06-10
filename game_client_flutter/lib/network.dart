import 'dart:async';
import 'dart:io';

import 'package:multiplayer_asteroids_common/common.dart';

class Network {
  StreamSubscription _subscription;
  Timer _pingTimer;

  void dispose() {
    _subscription?.cancel();
    _pingTimer.cancel();
  }

  void setupClient(void onGameState(GameState gameState)) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    print("Joining on socket ${socket.address.address}:${socket.port}");

    final destinationPort = 4444;
    _send(socket, destinationPort, "Joined");

    _pingTimer = Timer.periodic(Duration(seconds: 2),
        (_) => _send(socket, destinationPort, "Keep alive"));

    _subscription = socket.listen((event) {
      final datagram = socket.receive();

      if (datagram != null) {
        final json = String.fromCharCodes(datagram.data);
        final gameState = GameState.fromJson(json);
        onGameState(gameState);
      }
    });
  }

  void _send(RawDatagramSocket socket, int port, String message) {
    final request = Request((b) => b..type = message);
    final json = serializers.serialize(request).toString().codeUnits;
    socket.send(json, InternetAddress.anyIPv4, port);
  }
}
