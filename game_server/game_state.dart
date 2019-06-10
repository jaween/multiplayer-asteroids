import 'player.dart';

class Asteroid {
  double x;
  double y;
  double speed;
  double angle;
  double size;

  @override
  String toString() {
    return "($x,$y)";
  }
}

class GameState {
  List<Player> players = [];
  List<Asteroid> asteroids = [];
}