import 'dart:math';

import 'game_state.dart';

class GameLoop {
  static const double width = 1000;
  static const double height = 1000;

  GameState gameState;

  GameLoop() {
    gameState = _create();
  }

  GameState _create() {
    final random = Random();
    return GameState()
      ..asteroids = List.generate(random.nextInt(6) + 2, (_) {
        return Asteroid()
          ..angle = random.nextDouble() * pi * 2
          ..size = random.nextDouble() * 5 + 1
          ..x = random.nextDouble() * width
          ..y = random.nextDouble() * height
          ..speed = random.nextDouble() * 3 + 1;
      });
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

      asteroid.x = newX;
      asteroid.y = newY;
    });

    for (var i = 0; i < gameState.asteroids.length; i++) {
      print("  $i) ${gameState.asteroids[i]}");
    }
  }

  void addPlayer(String playerId) {

  }

  void removePlayer(String playerId) {
    
  }
}