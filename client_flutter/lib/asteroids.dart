import 'package:flutter/material.dart';
import 'package:multiplayer_asteroids_client_core/client_core.dart';
import 'package:multiplayer_asteroids_client_flutter/comms/comms_client_websocket.dart';
import 'package:multiplayer_asteroids_common/common.dart';

class Asteroids extends StatefulWidget {
  @override
  _AsteroidsState createState() => _AsteroidsState();
}

class _AsteroidsState extends State<Asteroids> {
  GameClient _gameClient;
  GameState _gameState;

  @override
  void initState() {
    super.initState();
    final host = "ws://192.168.1.117";
    final port = 8081;
    final comms = CommsClientWebsocket();
    _gameClient = GameClient(host, port, comms);
    _gameClient.start(onGameStateUpdated: (gameState) {
      setState(() => _gameState = gameState);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameClient.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameState == null) {
      return Center(
        child: Text("Connecting..."),
      );
    }
    return Container(
      constraints: BoxConstraints.expand(),
      child: CustomPaint(
        painter: AsteroidsPaint(_gameState),
      ),
    );
  }
}

class AsteroidsPaint extends CustomPainter {
  final GameState gameState;
  Paint _asteroidPaint;

  AsteroidsPaint(this.gameState) {
    _asteroidPaint = Paint();
    _asteroidPaint.color = Colors.white;
    _asteroidPaint.style = PaintingStyle.stroke;
    _asteroidPaint.strokeWidth = 2;
  }

  @override
  bool shouldRepaint(AsteroidsPaint oldDelegate) =>
      gameState != oldDelegate.gameState;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black, BlendMode.clear);
    gameState.asteroids.forEach((asteroid) {
      final offset = _posToOffset(asteroid.x, asteroid.y, size);
      final radius = _sizeToRadius(asteroid.size, size);
      canvas.drawCircle(offset, radius, _asteroidPaint);
    });
  }

  Offset _posToOffset(double x, double y, Size size) {
    return Offset(x / 1000 * size.width, y / 1000 * size.height);
  }

  double _sizeToRadius(double asteroidSize, Size size) {
    return asteroidSize / 1000 * size.width;
  }
}
