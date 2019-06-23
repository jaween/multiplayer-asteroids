import 'dart:html';

import 'package:multiplayer_asteroids_client_core/client_core.dart';
import 'package:multiplayer_asteroids_client_web/comms/comms_client_js.dart';
import 'package:multiplayer_asteroids_common/common.dart';

WorldState _worldState;
DebugInfo _debugInfo;

void main() {
  final CanvasElement canvas = querySelector('#canvas');
  final CanvasRenderingContext2D context = canvas.context2D;

  final host = "ws://192.168.1.21";
  final port = 8081;
  final comms = CommsClientJs();
  final _gameClient = GameClient(host, port, comms);
  _gameClient.start(
    onConnectionStateChanged: _onConnectionStateChanged,
    onWorldStateUpdated: (worldState) => _worldState = worldState,
    onDebugInfoUpdated: (debugInfo) => _debugInfo = debugInfo,
  );

  _handleInput(_gameClient);
  _onConnectionStateChanged(false);

  window.animationFrame.then((time) => _draw(canvas, context, _worldState));
}

void _onConnectionStateChanged(bool connected) {
  final p = querySelector('#debug');
  p.text = connected ? "Connected" : "Disconnected";
}

void _draw(
  CanvasElement canvas,
  CanvasRenderingContext2D context,
  WorldState worldState,
) {
  context.fillStyle = "black";
  context.fillRect(0, 0, canvas.width, canvas.height);

  if (worldState != null) {
    context.strokeStyle = "white";
    context.fillStyle = null;
    context.lineWidth = 2;
    worldState.asteroids.forEach((asteroid) {
      final offset =
          _posToOffset(asteroid.x, asteroid.y, canvas.width, canvas.height);
      final radius = _sizeToRadius(asteroid.size, canvas.width);
      context.beginPath();
      context.arc(offset.dx, offset.dy, radius, 0, 6.28);
      context.stroke();
    });

    final playerSize = _sizeToRadius(60, canvas.width);
    worldState.players.forEach((id, player) {
      final o = _posToOffset(player.x, player.y, canvas.width, canvas.height);
      context.translate(o.dx, o.dy);
      context.rotate(player.angle);

      context.beginPath();
      context.moveTo(-playerSize / 2, -playerSize / 3);
      context.lineTo(playerSize / 2, 0);
      context.lineTo(-playerSize / 2, playerSize / 3);
      context.lineTo(-playerSize / 3, 0);
      context.closePath();
      context.stroke();

      context.rotate(-player.angle);
      context.translate(-o.dx, -o.dy);
    });
  }

  window.animationFrame.then((time) => _draw(canvas, context, _worldState));
}

Offset _posToOffset(double x, double y, int width, int height) {
  return Offset(x / 1000 * width, y / 1000 * height);
}

double _sizeToRadius(double asteroidSize, int width) {
  return asteroidSize / 1000 * width;
}

class Offset {
  final double dx;
  final double dy;
  Offset(this.dx, this.dy);
}

void _handleInput(GameClient gameClient) {
  window.onKeyDown.listen((e) {
    String action = _keyCodeToAction(e.keyCode);
    if (action != null) {
      gameClient.input(true, action);
    }
  });
  window.onKeyUp.listen((e) {
    String action = _keyCodeToAction(e.keyCode);
    if (action != null) {
      gameClient.input(false, action);
    }
  });
}

String _keyCodeToAction(int keyCode) {
  if (keyCode == KeyCode.LEFT) {
    return "left";
  } else if (keyCode == KeyCode.UP) {
    return "up";
  } else if (keyCode == KeyCode.RIGHT) {
    return "right";
  } else {
    return null;
  }
}
