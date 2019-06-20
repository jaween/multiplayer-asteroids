import 'dart:async';

import 'package:multiplayer_asteroids_common/common.dart';

class GameClient {
  final String _host;
  final int _port;
  final CommsClient _commsClient;

  Timer _pingTimer;
  StreamSubscription _subscription;

  GameClient(this._host, this._port, this._commsClient);

  void start(void onGameStateUpdated(GameState gameState)) {
    _commsClient.start(_host, _port, _onConnected);
  }

  void dispose() {
    // TODO: Maybe the caller should be closing the CommsClient
    _commsClient?.close();
  }

  void _onConnected(Socket socket) {
    print("Connected");
    socket.listen(_onMessage);
    _pingTimer = Timer.periodic(
        Duration(seconds: 2), (_) => _send(socket, "Keep alive"));
  }

  void _send(Socket socket, String message) {
    final request = Request((b) => b..type = message);
    final json = serializers.serialize(request).toString().codeUnits;
    //socket.send(json, InternetAddress("192.168.1.117"), port);
    socket.send(json);
  }

  void _onMessage(dynamic data) {
    print("received data");
    print(data);
  }
}
