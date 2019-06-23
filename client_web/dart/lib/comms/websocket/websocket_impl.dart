@JS()
library websocket_js_impl;

import 'package:multiplayer_asteroids_common/common.dart';
import 'package:js/js.dart';

@JS()
class WebSocketClient implements CommsClient {
  external factory WebSocketClient();
  external void start(
    String host,
    int port,
    void onConnected(WebSocket socket),
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
