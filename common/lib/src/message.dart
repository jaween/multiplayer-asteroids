import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:multiplayer_asteroids_common/src/serializers.dart';
import 'package:multiplayer_asteroids_common/src/user_command.dart';
import 'package:multiplayer_asteroids_common/src/world_state.dart';

part 'message.g.dart';

@BuiltValue(instantiable: false)
abstract class Message {
  static fromJson(String jsonString) =>
      messageSerializers.deserialize(jsonDecode(jsonString));
}

/// Information for clients when they first connect to the server.
@BuiltValue(wireName: "connectMessage")
abstract class ConnectMessage
    implements Message, Built<ConnectMessage, ConnectMessageBuilder> {
  int get playerId;
  int get serverTick;
  int get serverStateUpdateMs;
  int get serverStatePublishMs;

  ConnectMessage._();
  factory ConnectMessage([updates(ConnectMessageBuilder b)]) = _$ConnectMessage;
  static Serializer<ConnectMessage> get serializer =>
      _$connectMessageSerializer;

  static ConnectMessage fromJson(String jsonString) => serializers
      .deserializeWith(ConnectMessage.serializer, jsonDecode(jsonString));
}

/// State of the world at a given tick;
@BuiltValue(wireName: "worldStateMessage")
abstract class WorldStateMessage
    implements Message, Built<WorldStateMessage, WorldStateMessageBuilder> {
  int get serverTick;
  WorldState get worldState;

  WorldStateMessage._();
  factory WorldStateMessage([updates(WorldStateMessageBuilder b)]) =
      _$WorldStateMessage;
  static Serializer<WorldStateMessage> get serializer =>
      _$worldStateMessageSerializer;

  static WorldStateMessage fromJson(String jsonString) => serializers
      .deserializeWith(WorldStateMessage.serializer, jsonDecode(jsonString));
}

/// Input state at a given tick;
@BuiltValue(wireName: "userCommandMessage")
abstract class UserCommandMessage
    implements Message, Built<UserCommandMessage, UserCommandMessageBuilder> {
  int get tick;
  UserCommand get userCommand;

  UserCommandMessage._();
  factory UserCommandMessage([updates(UserCommandMessageBuilder b)]) =
      _$UserCommandMessage;
  static Serializer<UserCommandMessage> get serializer =>
      _$userCommandMessageSerializer;

  static UserCommandMessage fromJson(String jsonString) => serializers
      .deserializeWith(UserCommandMessage.serializer, jsonDecode(jsonString));
}
