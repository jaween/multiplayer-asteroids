import 'dart:js';

import 'package:js/js.dart';
import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_client_web/comms/websocket/websocket_impl.dart';

/// Implementation of network communications for JavaScript clients (via
/// WebSockets).
class CommsClientJs implements CommsClient {
  WebSocketClient _webSocketClient;

  @override
  void start(String host, int port, void onConnected(Socket socket)) {
    _webSocketClient?.close();
    _webSocketClient = WebSocketClient();
    _webSocketClient.start(host, port, allowInterop((socket) {
      onConnected(_SocketInteropWrapper(socket));
    }));
  }

  @override
  void close() => _webSocketClient?.close();
}

/// Wraps the Socket to allow a Dart function to be used as a callback for the
/// onMessage parameter of the Socket.listen method.
class _SocketInteropWrapper implements Socket {
  final Socket _socket;

  _SocketInteropWrapper(this._socket);

  @override
  void listen(void onMessage(data)) => _socket.listen(allowInterop(onMessage));

  @override
  void send(data) => _socket.send(data);

  @override
  void close() => _socket.close();
}
