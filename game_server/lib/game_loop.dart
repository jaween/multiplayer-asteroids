import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:multiplayer_asteroids_common/common.dart';

class GameLoop {
  static const double width = 1000;
  static const double height = 1000;

  GameState gameState;

  GameLoop() {
    gameState = _create();
  }

  GameState _create() {
    final random = Random();

    final asteroidsList = List.generate(random.nextInt(6) + 2, (_) {
      return Asteroid((b) => b
        ..angle = random.nextDouble() * pi * 2
        ..size = random.nextDouble() * 5 + 1
        ..x = random.nextDouble() * width
        ..y = random.nextDouble() * height
        ..speed = random.nextDouble() * 3 + 1);
    });

    return GameState((b) => b
      ..asteroids = BuiltList.of(asteroidsList).toBuilder()
      ..players = BuiltList.of(<Player>[]).toBuilder());
  }

  void update() {
    // Asteroid locations
    gameState.asteroids.forEach((asteroid) {
      var newX = asteroid.x + cos(asteroid.angle) * asteroid.speed;
      var newY = asteroid.y + sin(asteroid.angle) * asteroid.speed;

      // Horizontal wrapping
      if (newX < -asteroid.size) {
        newX = width;
      } else if (newX > width) {
        newX = -asteroid.size;
      }

      // Vertical wrapping
      if (newY < -asteroid.size) {
        newY = height;
      } else if (newY > height) {
        newY = -asteroid.size;
      }

      asteroid = asteroid
        ..rebuild((b) => b
          ..x = newX
          ..y = newY);
    });
  }

  void addPlayer(String playerId) {}

  void removePlayer(String playerId) {}
}
