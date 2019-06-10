import 'package:built_collection/built_collection.dart';
import 'package:multiplayer_asteroids_common/src/asteroid.dart';
import 'package:multiplayer_asteroids_common/src/player.dart';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_state.g.dart';

abstract class GameState implements Built<GameState, GameStateBuilder> {
  BuiltList<Player> get players;
  BuiltList<Asteroid> get asteroids;

  GameState._();
  factory GameState([updates(GameStateBuilder b)]) = _$GameState;
  static Serializer<GameState> get serializer => _$gameStateSerializer;
}
