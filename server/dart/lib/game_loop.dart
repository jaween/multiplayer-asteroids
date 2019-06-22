import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:multiplayer_asteroids_common/common.dart';

class GameLoop {
  static const double width = 1000;
  static const double height = 1000;

  WorldState worldState;

  GameLoop() {
    worldState = _create();
  }

  WorldState _create() {
    final random = Random();

    final asteroidsList = List.generate(random.nextInt(10) + 2, (_) {
      return Asteroid((b) => b
        ..angle = random.nextDouble() * pi * 2
        ..size = random.nextDouble() * 40 + 10
        ..x = random.nextDouble() * width
        ..y = random.nextDouble() * height
        ..speed = random.nextDouble() * 2 + 3);
    });

    return WorldState((b) => b
      ..asteroids = BuiltList.of(asteroidsList).toBuilder()
      ..players = BuiltList.of(<Player>[]).toBuilder());
  }

  void update() {
    // Asteroid locations
    worldState = worldState.rebuild((b) {
      final asteroids = b.asteroids.build().map((asteroid) {
        var newX = asteroid.x + cos(asteroid.angle) * asteroid.speed;
        var newY = asteroid.y + sin(asteroid.angle) * asteroid.speed;

        // Horizontal wrapping
        if (newX < -asteroid.size) {
          newX = width + asteroid.size;
        } else if (newX > width + asteroid.size) {
          newX = -asteroid.size;
        }

        // Vertical wrapping
        if (newY < -asteroid.size) {
          newY = height + asteroid.size;
        } else if (newY > height + asteroid.size) {
          newY = -asteroid.size;
        }

        return Asteroid(((b) => b
          ..x = newX
          ..y = newY
          ..speed = asteroid.speed
          ..size = asteroid.size
          ..angle = asteroid.angle));
      }).toList(growable: false);

      b.asteroids = BuiltList<Asteroid>.from(asteroids).toBuilder();
    });
  }

  void addPlayer(String playerId) {}

  void removePlayer(String playerId) {}
}
