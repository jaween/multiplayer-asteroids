// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GameState> _$gameStateSerializer = new _$GameStateSerializer();

class _$GameStateSerializer implements StructuredSerializer<GameState> {
  @override
  final Iterable<Type> types = const [GameState, _$GameState];
  @override
  final String wireName = 'GameState';

  @override
  Iterable serialize(Serializers serializers, GameState object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'players',
      serializers.serialize(object.players,
          specifiedType:
              const FullType(BuiltList, const [const FullType(Player)])),
      'asteroids',
      serializers.serialize(object.asteroids,
          specifiedType:
              const FullType(BuiltList, const [const FullType(Asteroid)])),
    ];

    return result;
  }

  @override
  GameState deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GameStateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'players':
          result.players.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(Player)]))
              as BuiltList);
          break;
        case 'asteroids':
          result.asteroids.replace(serializers.deserialize(value,
              specifiedType: const FullType(
                  BuiltList, const [const FullType(Asteroid)])) as BuiltList);
          break;
      }
    }

    return result.build();
  }
}

class _$GameState extends GameState {
  @override
  final BuiltList<Player> players;
  @override
  final BuiltList<Asteroid> asteroids;

  factory _$GameState([void Function(GameStateBuilder) updates]) =>
      (new GameStateBuilder()..update(updates)).build();

  _$GameState._({this.players, this.asteroids}) : super._() {
    if (players == null) {
      throw new BuiltValueNullFieldError('GameState', 'players');
    }
    if (asteroids == null) {
      throw new BuiltValueNullFieldError('GameState', 'asteroids');
    }
  }

  @override
  GameState rebuild(void Function(GameStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameStateBuilder toBuilder() => new GameStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameState &&
        players == other.players &&
        asteroids == other.asteroids;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, players.hashCode), asteroids.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('GameState')
          ..add('players', players)
          ..add('asteroids', asteroids))
        .toString();
  }
}

class GameStateBuilder implements Builder<GameState, GameStateBuilder> {
  _$GameState _$v;

  ListBuilder<Player> _players;
  ListBuilder<Player> get players =>
      _$this._players ??= new ListBuilder<Player>();
  set players(ListBuilder<Player> players) => _$this._players = players;

  ListBuilder<Asteroid> _asteroids;
  ListBuilder<Asteroid> get asteroids =>
      _$this._asteroids ??= new ListBuilder<Asteroid>();
  set asteroids(ListBuilder<Asteroid> asteroids) =>
      _$this._asteroids = asteroids;

  GameStateBuilder();

  GameStateBuilder get _$this {
    if (_$v != null) {
      _players = _$v.players?.toBuilder();
      _asteroids = _$v.asteroids?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GameState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$GameState;
  }

  @override
  void update(void Function(GameStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$GameState build() {
    _$GameState _$result;
    try {
      _$result = _$v ??
          new _$GameState._(
              players: players.build(), asteroids: asteroids.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'players';
        players.build();
        _$failedField = 'asteroids';
        asteroids.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'GameState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
