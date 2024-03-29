const IsoWebSocket = require('isomorphic-ws');

class WebSocketServer {
  start(port, onConnection) {
    this.binding = new IsoWebSocket.Server({ port: port });
    this.binding.on('connection', function (socket, request) {
      onConnection(
        new WebSocket(socket),
        {
          'address': request.connection.remoteAddress,
          'port': request.connection.remotePort,
        }
      );
    });
  }

  close() {
    this.binding.close();
  }
}

class WebSocket {
  constructor(socket) {
    this.socket = socket;
  }

  send(data) {
    this.socket.send(data);
  }

  listen(onMessage) {
    this.socket.on('message', function message(data) {
      onMessage(data);
    });
  }

  close() {
    this.socket.close();
  }
}

module.exports = {
  WebSocketServer,
  WebSocket
};
