function dartMainRunner(main, args) {
  self.websocket_impl = require('../js/websocket_impl.js');
  self.WebSocketServer = self.websocket_impl.WebSocketServer;
  self.Socket = self.websocket_impl.Socket;
  main(args);
}
