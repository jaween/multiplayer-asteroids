import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_command.g.dart';

abstract class UserCommand implements Built<UserCommand, UserCommandBuilder> {
  BuiltSet<String> get commands;

  UserCommand._();
  factory UserCommand([updates(UserCommandBuilder b)]) = _$UserCommand;
  static Serializer<UserCommand> get serializer => _$userCommandSerializer;
}
