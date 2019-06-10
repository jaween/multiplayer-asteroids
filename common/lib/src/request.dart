import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:multiplayer_asteroids_common/src/game_state.dart';
import 'package:multiplayer_asteroids_common/src/serializers.dart';

part 'request.g.dart';

abstract class Request implements Built<Request, RequestBuilder> {
  String get type;

  @nullable
  GameState get state;

  Request._();
  factory Request([updates(RequestBuilder b)]) = _$Request;
  static Serializer<Request> get serializer => _$requestSerializer;

  static fromJson(String jsonString) =>
      serializers.deserializeWith(Request.serializer, jsonDecode(jsonString));
}