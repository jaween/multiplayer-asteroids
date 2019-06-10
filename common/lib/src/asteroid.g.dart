// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asteroid.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Asteroid> _$asteroidSerializer = new _$AsteroidSerializer();

class _$AsteroidSerializer implements StructuredSerializer<Asteroid> {
  @override
  final Iterable<Type> types = const [Asteroid, _$Asteroid];
  @override
  final String wireName = 'Asteroid';

  @override
  Iterable serialize(Serializers serializers, Asteroid object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'x',
      serializers.serialize(object.x, specifiedType: const FullType(double)),
      'y',
      serializers.serialize(object.y, specifiedType: const FullType(double)),
      'speed',
      serializers.serialize(object.speed,
          specifiedType: const FullType(double)),
      'angle',
      serializers.serialize(object.angle,
          specifiedType: const FullType(double)),
      'size',
      serializers.serialize(object.size, specifiedType: const FullType(double)),
    ];

    return result;
  }

  @override
  Asteroid deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new AsteroidBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'x':
          result.x = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'y':
          result.y = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'speed':
          result.speed = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'angle':
          result.angle = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'size':
          result.size = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
      }
    }

    return result.build();
  }
}

class _$Asteroid extends Asteroid {
  @override
  final double x;
  @override
  final double y;
  @override
  final double speed;
  @override
  final double angle;
  @override
  final double size;

  factory _$Asteroid([void Function(AsteroidBuilder) updates]) =>
      (new AsteroidBuilder()..update(updates)).build();

  _$Asteroid._({this.x, this.y, this.speed, this.angle, this.size})
      : super._() {
    if (x == null) {
      throw new BuiltValueNullFieldError('Asteroid', 'x');
    }
    if (y == null) {
      throw new BuiltValueNullFieldError('Asteroid', 'y');
    }
    if (speed == null) {
      throw new BuiltValueNullFieldError('Asteroid', 'speed');
    }
    if (angle == null) {
      throw new BuiltValueNullFieldError('Asteroid', 'angle');
    }
    if (size == null) {
      throw new BuiltValueNullFieldError('Asteroid', 'size');
    }
  }

  @override
  Asteroid rebuild(void Function(AsteroidBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AsteroidBuilder toBuilder() => new AsteroidBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Asteroid &&
        x == other.x &&
        y == other.y &&
        speed == other.speed &&
        angle == other.angle &&
        size == other.size;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, x.hashCode), y.hashCode), speed.hashCode),
            angle.hashCode),
        size.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Asteroid')
          ..add('x', x)
          ..add('y', y)
          ..add('speed', speed)
          ..add('angle', angle)
          ..add('size', size))
        .toString();
  }
}

class AsteroidBuilder implements Builder<Asteroid, AsteroidBuilder> {
  _$Asteroid _$v;

  double _x;
  double get x => _$this._x;
  set x(double x) => _$this._x = x;

  double _y;
  double get y => _$this._y;
  set y(double y) => _$this._y = y;

  double _speed;
  double get speed => _$this._speed;
  set speed(double speed) => _$this._speed = speed;

  double _angle;
  double get angle => _$this._angle;
  set angle(double angle) => _$this._angle = angle;

  double _size;
  double get size => _$this._size;
  set size(double size) => _$this._size = size;

  AsteroidBuilder();

  AsteroidBuilder get _$this {
    if (_$v != null) {
      _x = _$v.x;
      _y = _$v.y;
      _speed = _$v.speed;
      _angle = _$v.angle;
      _size = _$v.size;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Asteroid other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Asteroid;
  }

  @override
  void update(void Function(AsteroidBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Asteroid build() {
    final _$result = _$v ??
        new _$Asteroid._(x: x, y: y, speed: speed, angle: angle, size: size);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
