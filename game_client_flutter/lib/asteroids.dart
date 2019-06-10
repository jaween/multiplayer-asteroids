import 'package:flutter/material.dart';
import 'package:multiplayer_asteroids_common/common.dart';
import 'package:multiplayer_asteroids_game_flutter/network.dart';

class Asteroids extends StatefulWidget {
  @override
  _AsteroidsState createState() => _AsteroidsState();
}

class _AsteroidsState extends State<Asteroids> {
  GameState _gameState;

  final _network = Network();

  @override
  void initState() {
    super.initState();
    _network.setupClient((gameState) {
      setState(() => this._gameState = gameState);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _network.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameState == null) {
      return Center(
        child: Text("Connecting..."),
      );
    }
    return CustomPaint(
      painter: AsteroidsPaint(_gameState),
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
    canvas.drawColor(Colors.black, BlendMode.color);

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