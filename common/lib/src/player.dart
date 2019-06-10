import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'player.g.dart';

abstract class Player implements Built<Player, PlayerBuilder> {
  String get name;
  String get x;
  String get y;

  Player._();
  factory Player([updates(PlayerBuilder b)]) = _$Player;
  static Serializer<Player> get serializer => _$playerSerializer;
}
