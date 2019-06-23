function dartMainRunner(main, args) {
  self.websocket_impl = require('../js/websocket_impl.js');
  self.WebSocketClient = self.websocket_impl.WebSocketClient;
  self.Socket = self.websocket_impl.Socket;
  main(args);
}
