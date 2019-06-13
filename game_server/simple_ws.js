const WebSocket = require('ws');

const port = process.env.PORT || 8080;

const server = new WebSocket.Server({
  port: port,
});

console.log(`Starting simple server on port ${port}`);
server.on('connection', function connection(socket) {
  socket.on('message', function incoming(message) {
    console.log(`Received: '${message}'`);
  });

  socket.send('Thanks for your connection!');
});
