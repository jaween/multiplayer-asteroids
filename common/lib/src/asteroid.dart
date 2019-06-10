import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'asteroid.g.dart';

abstract class Asteroid implements Built<Asteroid, AsteroidBuilder> {
  double get x;
  double get y;
  double get speed;
  double get angle;
  double get size;

  Asteroid._();
  factory Asteroid([updates(AsteroidBuilder b)]) = _$Asteroid;
  static Serializer<Asteroid> get serializer => _$asteroidSerializer;
}
