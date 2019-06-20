import 'dart:async';
import 'dart:io';

import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_common/common.dart' as Common;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class CommsClientWebsocket implements CommsClient {
  WebSocketChannel _channel;
  WebSocket _socket;

  @override
  void start(
      String host, int port, void Function(Common.Socket socket) onConnected) {
    Timer timer;
    timer = Timer.periodic(Duration(seconds: 2), (_) async {
      try {
        _socket?.close();
        _socket = await WebSocket.connect('$host:$port');
        _channel = IOWebSocketChannel(_socket);
        timer.cancel();
        onConnected(_WebSocketWrapper(_socket));
      } on SocketException catch (e) {
        print("Could not connect to socket, $e");
      } on TimeoutException catch (e) {
        print("Could not connect, timeout $e");
      }
    });
  }

  @override
  void close() {
    _channel.sink.close();
  }
}

class _WebSocketWrapper implements Common.Socket {
  final WebSocket _webSocket;

  _WebSocketWrapper(this._webSocket);

  @override
  void send(data) => _webSocket.add(data);

  @override
  void listen(void onMessage(data)) =>
      _webSocket.listen((data) => onMessage(data));

  @override
  void close() => _webSocket.close();
}
