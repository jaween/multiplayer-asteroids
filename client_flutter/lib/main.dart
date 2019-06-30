import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:multiplayer_asteroids_client_flutter/asteroids.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(Game());
}

class Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: AsteroidsWrapper(),
      ),
    );
  }
}

class AsteroidsWrapper extends StatefulWidget {
  @override
  _AsteroidsWrapperState createState() => _AsteroidsWrapperState();
}

class _AsteroidsWrapperState extends State<AsteroidsWrapper> {
  var _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Asteroids(key: _key, restart: _restart);
  }

  void _restart() => setState(() => _key = UniqueKey());
}
