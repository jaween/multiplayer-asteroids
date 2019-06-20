import 'dart:js';

import 'package:js/js.dart';
import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_server/comms/websocket/websocket_impl.dart';

/// Implementation of network communications for JavaScript (WebSockets for
/// Node server and browser client).
class CommsServerJs implements CommsServer {
  WebSocketServer _webSocketServer;

  @override
  void start(int port, void onConnection(Socket socket, ClientInfo client)) {
    _webSocketServer?.close();
    _webSocketServer = WebSocketServer();
    _webSocketServer.start(port, allowInterop((socket, client) {
      onConnection(_SocketInteropWrapper(socket), client);
    }));
  }

  @override
  void close() => _webSocketServer?.close();
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
