import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:multiplayer_asteroids_common/src/asteroid.dart';
import 'package:multiplayer_asteroids_common/src/message.dart';
import 'package:multiplayer_asteroids_common/src/player.dart';
import 'package:multiplayer_asteroids_common/src/request.dart';
import 'package:multiplayer_asteroids_common/src/world_state.dart';

part 'serializers.g.dart';

/// Serializers for network messages
@SerializersFor(const [
  ConnectMessage,
  WorldStateMessage,
])
final Serializers messageSerializers = (_$messageSerializers.toBuilder()
      ..addPlugin(StandardJsonPlugin(discriminator: "\$")))
    .build();

/// Serializers for general objects
@SerializersFor(const [
  Asteroid,
  WorldState,
  Player,
  Request,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(new StandardJsonPlugin())).build();
