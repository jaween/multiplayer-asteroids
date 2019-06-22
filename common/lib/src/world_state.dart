import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:multiplayer_asteroids_common/src/asteroid.dart';
import 'package:multiplayer_asteroids_common/src/player.dart';

part 'world_state.g.dart';

abstract class WorldState implements Built<WorldState, WorldStateBuilder> {
  BuiltMap<int, Player> get players;
  BuiltList<Asteroid> get asteroids;

  WorldState._();
  factory WorldState([updates(WorldStateBuilder b)]) = _$WorldState;
  static Serializer<WorldState> get serializer => _$worldStateSerializer;
}
