import 'dart:ui';

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
  WorldState _worldState;
  bool _connected = false;
  DebugInfo _debugInfo;

  @override
  void initState() {
    super.initState();
    final host = "ws://192.168.1.21";
    final port = 8081;
    final comms = CommsClientWebsocket();
    _gameClient = GameClient(host, port, comms);
    _gameClient.start(onConnectionStateChanged: (connected) {
      setState(() => _connected = connected);
    }, onWorldStateUpdated: (worldState) {
      setState(() => _worldState = worldState);
    }, onDebugInfoUpdated: (debugInfo) {
      setState(() => _debugInfo = debugInfo);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameClient.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_connected) {
      return Center(
        child: Text("Connecting..."),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: AsteroidsPaint(_worldState),
        ),
        _buildControls(),
        _buildDebugInfo(),
      ],
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _buildInputButton("▲", "up"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildInputButton("◀", "left"),
                  _buildInputButton("▼", "down"),
                  _buildInputButton("▶", "right"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputButton(String label, String action) {
    return Listener(
      child: InkWell(
        splashColor: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 80,
            height: 60,
            child: Center(
              child: Text(label, style: Theme.of(context).textTheme.headline),
            ),
          ),
        ),
        onTap: () {},
      ),
      onPointerDown: (_) => _action(true, action),
      onPointerUp: (_) => _action(false, action),
      onPointerCancel: (_) => _action(false, action),
    );
  }

  void _action(bool down, String action) => _gameClient.input(down, action);

  Widget _buildDebugInfo() {
    if (_debugInfo != null)
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade800.withOpacity(0.4),
              child: Text(
                  "Initial tick: ${_debugInfo.connectMessage?.serverTick}\n"
                  "Update rate: ${_debugInfo.connectMessage?.serverStateUpdateMs}ms\n"
                  "RTT: ${_debugInfo.rttMs.toStringAsFixed(1)}ms\n"
                  "Interpolation delay: ${_debugInfo.interpolationDelayMs.toStringAsFixed(1)}ms"),
            ),
          ),
        ),
      );
    else
      return Container();
  }
}

class AsteroidsPaint extends CustomPainter {
  final WorldState worldState;
  Paint _asteroidPaint;

  AsteroidsPaint(this.worldState) {
    _asteroidPaint = Paint();
    _asteroidPaint.color = Colors.white;
    _asteroidPaint.style = PaintingStyle.stroke;
    _asteroidPaint.strokeWidth = 2;
  }

  @override
  bool shouldRepaint(AsteroidsPaint oldDelegate) =>
      worldState != oldDelegate.worldState;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black, BlendMode.clear);

    if (worldState == null) {
      return;
    }

    worldState.asteroids.forEach((asteroid) {
      final offset = _posToOffset(asteroid.x, asteroid.y, size);
      final radius = _sizeToRadius(asteroid.size, size);
      canvas.drawCircle(offset, radius, _asteroidPaint);
    });

    final playerSize = _sizeToRadius(60, size);
    final shipPath = Path()
      ..moveTo(-playerSize / 2, -playerSize / 3)
      ..lineTo(playerSize / 2, 0)
      ..lineTo(-playerSize / 2, playerSize / 3)
      ..lineTo(-playerSize / 3, 0)
      ..close();
    worldState.players.forEach((id, player) {
      final o = _posToOffset(player.x, player.y, size);
      final transformed = shipPath
          .transform(Matrix4.rotationZ(player.angle).storage)
          .transform(Matrix4.translationValues(o.dx, o.dy, 0).storage);
      canvas.drawPath(transformed, _asteroidPaint);
    });
  }

  Offset _posToOffset(double x, double y, Size size) {
    return Offset(x / 1000 * size.width, y / 1000 * size.height);
  }

  double _sizeToRadius(double asteroidSize, Size size) {
    return asteroidSize / 1000 * size.width;
  }
}
