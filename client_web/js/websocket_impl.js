const IsoWebSocket = require('isomorphic-ws');

class WebSocketClient {
  start(host, port, onConnected) {
    this.socket = new IsoWebSocket(`${host}:${port}`);
    var socket = this.socket;
    this.socket.onopen = function () {
      onConnected(new WebSocket(socket));
    };
  }

  close() {
    this.socket.close();
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
    this.socket.onmessage = function (event) {
      var reader = new FileReader();
      reader.onload = () => {
        var arrayBuffer = reader.result;
        var bytes = new Uint8Array(arrayBuffer);
        onMessage(bytes);
      };
      reader.readAsArrayBuffer(event.data);
    };
  }

  close() {
    this.socket.close();
  }
}

module.exports = {
  WebSocketClient,
  WebSocket
};