import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:multiplayer_asteroids_common/src/asteroid.dart';

part 'serializers.g.dart';

@SerializersFor(const [
    Asteroid,
])
final Serializers serializers =
(_$serializers.toBuilder()..addPlugin(new StandardJsonPlugin())).build();