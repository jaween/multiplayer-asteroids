@JS()
library websocket_js_impl;

import 'package:multiplayer_asteroids_common/common.dart';
import 'package:js/js.dart';

@JS()
class WebSocketServer implements CommsServer {
  external factory WebSocketServer();
  external void start(
    int port,
    void onConnection(WebSocket socket, ClientInfo client),
  );
  external void close();
}

@JS()
class WebSocket implements Socket {
  external factory WebSocket();
  external void send(data);
  external void listen(void onMessage(data));
  external void close();
}

@JS()
@anonymous
class WebSocketClientInfo implements ClientInfo {
  external String get address;
  external int get port;
  external factory WebSocketClientInfo({
    String address,
    int port,
  });
}
