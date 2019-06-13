import 'dart:html';
import 'dart:convert';

void main() {
  print("I am Dart");

  final CanvasElement canvas = querySelector('#canvas');
  final CanvasRenderingContext2D context = canvas.context2D;
  context.fillStyle = "black";
  context.fillRect(0, 0, canvas.width, canvas.height);

  final p = querySelector('#debug');
  p.text = "Connected";

  //final host = 'localhost';
  final host = 'jaween-multiplayer-asteroids.herokuapp.com';
  final port = 80;
  //final port = 8001;
  var webSocket = WebSocket('ws://$host:$port');
  webSocket.onOpen.first.then((_) {
    webSocket.onMessage.listen((MessageEvent e) {
      final Blob blob = e.data;
      final reader = FileReader();
      reader.readAsArrayBuffer(blob);
      reader.onLoadEnd.listen((_) {
        final data = reader.result;
        final json = String.fromCharCodes(data);
        updateDomWithJson(json, canvas, context);
      });
    });
  });
  webSocket.onError.first.then((_) {
    p.text = "Couldn't connect :(";
  });
}

void updateDomWithJson(
  String json,
  CanvasElement canvas,
  CanvasRenderingContext2D context,
) {
  context.fillStyle = "black";
  context.fillRect(0, 0, canvas.width, canvas.height);

  final decoded = jsonDecode(json);
  final asteroids = decoded['asteroids'];
  for (var asteroid in asteroids) {
    final x = asteroid['x'] / 1000 * canvas.width;
    final y = asteroid['y'] / 1000 * canvas.height;
    final radius = asteroid['size'] / 1000 * canvas.width;
    context.strokeStyle = "white";
    context.fillStyle = null;
    context.lineWidth = 3;
    context.beginPath();
    context.arc(x, y, radius, 0, 6.28);
    context.stroke();
  }
}
