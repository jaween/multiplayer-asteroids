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
      ..players = BuiltMap<int, Player>().toBuilder());
  }

  void update(Map<int, Set<String>> userCommands) {
    worldState = worldState.rebuild((b) {
      // Asteroid locations
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

      // Player locations and actions
      final updatedPlayers = <int, Player>{};
      final currentPlayers = worldState.players;
      currentPlayers.forEach((id, player) {
        final commands = userCommands[id] ?? {};
        updatedPlayers[id] = updatePlayer(player, commands);
      });
      b.players = BuiltMap<int, Player>.of(updatedPlayers).toBuilder();
    });
  }

  Player updatePlayer(Player player, Iterable<String> userCommands) {
    return player.rebuild((b) {
      final friction = 0.99;
      final acc = 0.08;
      b.velX *= friction;
      b.velY *= friction;
      for (var userCommand in userCommands) {
        final rotationSpeed = 4;
        switch (userCommand) {
          case "left":
            b.angle -= rotationSpeed * pi / 180;
            break;
          case "right":
            b.angle += rotationSpeed * pi / 180;
            break;
          case "up":
            b.velX += cos(player.angle) * acc;
            b.velY += sin(player.angle) * acc;
            break;
        }
      }
      b.velX.clamp(0, 2);
      b.velY.clamp(0, 2);

      var newX = b.x + b.velX;
      var newY = b.y + b.velY;

      // Horizontal wrapping
      final playerSize = 60 / 2;
      if (newX < -playerSize) {
        newX = width + playerSize;
      } else if (newX > width + playerSize) {
        newX = -playerSize;
      }

      // Vertical wrapping
      if (newY < -playerSize) {
        newY = height + playerSize;
      } else if (newY > height + playerSize) {
        newY = -playerSize;
      }

      b.x = newX;
      b.y = newY;
    });
  }

  void addPlayer(int playerId) {
    final random = Random();
    worldState = worldState.rebuild((b) {
      b.players[playerId] = Player((b) {
        b
          ..name = "Player $playerId"
          ..x = random.nextDouble() * (width * 0.2 + width * 0.8)
          ..y = random.nextDouble() * (height * 0.2 + height * 0.8)
          ..angle = random.nextDouble() * 2 * pi
          ..velX = 0
          ..velY = 0;
      });
    });
  }

  void removePlayer(int playerId) {
    worldState = worldState.rebuild((b) {
      b.players.remove(playerId);
    });
  }
}
