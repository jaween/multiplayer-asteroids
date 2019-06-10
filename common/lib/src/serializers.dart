import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:multiplayer_asteroids_common/src/asteroid.dart';
import 'package:multiplayer_asteroids_common/src/game_state.dart';
import 'package:multiplayer_asteroids_common/src/player.dart';
import 'package:multiplayer_asteroids_common/src/request.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  Asteroid,
  GameState,
  Player,
  Request,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(new StandardJsonPlugin())).build();
