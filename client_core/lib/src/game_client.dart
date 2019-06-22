import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:multiplayer_asteroids_common/common.dart';

typedef OnWorldStateUpdated = void Function(WorldState worldState);

class GameClient {
  final String _host;
  final int _port;
  final CommsClient _commsClient;
  OnWorldStateUpdated _onWorldStateUpdated;

  Timer _pingTimer;
  StreamSubscription _subscription;

  GameClient(this._host, this._port, this._commsClient);

  void start({@required void onWorldStateUpdated(WorldState worldState)}) {
    _onWorldStateUpdated = onWorldStateUpdated;
    _commsClient.start(_host, _port, _onConnected);
  }

  void dispose() {
    _commsClient?.close();
    _pingTimer?.cancel();
    _subscription?.cancel();
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
    print("connect message: $message");
  }

  void _onWorldStateMessage(WorldStateMessage message) {
    _onWorldStateUpdated(message.worldState);
  }
}
