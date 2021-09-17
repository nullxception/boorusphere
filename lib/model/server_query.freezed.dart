// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'server_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$ServerQueryTearOff {
  const _$ServerQueryTearOff();

  _ServerQuery call({String tags = '*', bool safeMode = true}) {
    return _ServerQuery(
      tags: tags,
      safeMode: safeMode,
    );
  }
}

/// @nodoc
const $ServerQuery = _$ServerQueryTearOff();

/// @nodoc
mixin _$ServerQuery {
  String get tags => throw _privateConstructorUsedError;
  bool get safeMode => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ServerQueryCopyWith<ServerQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerQueryCopyWith<$Res> {
  factory $ServerQueryCopyWith(
          ServerQuery value, $Res Function(ServerQuery) then) =
      _$ServerQueryCopyWithImpl<$Res>;
  $Res call({String tags, bool safeMode});
}

/// @nodoc
class _$ServerQueryCopyWithImpl<$Res> implements $ServerQueryCopyWith<$Res> {
  _$ServerQueryCopyWithImpl(this._value, this._then);

  final ServerQuery _value;
  // ignore: unused_field
  final $Res Function(ServerQuery) _then;

  @override
  $Res call({
    Object? tags = freezed,
    Object? safeMode = freezed,
  }) {
    return _then(_value.copyWith(
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      safeMode: safeMode == freezed
          ? _value.safeMode
          : safeMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$ServerQueryCopyWith<$Res>
    implements $ServerQueryCopyWith<$Res> {
  factory _$ServerQueryCopyWith(
          _ServerQuery value, $Res Function(_ServerQuery) then) =
      __$ServerQueryCopyWithImpl<$Res>;
  @override
  $Res call({String tags, bool safeMode});
}

/// @nodoc
class __$ServerQueryCopyWithImpl<$Res> extends _$ServerQueryCopyWithImpl<$Res>
    implements _$ServerQueryCopyWith<$Res> {
  __$ServerQueryCopyWithImpl(
      _ServerQuery _value, $Res Function(_ServerQuery) _then)
      : super(_value, (v) => _then(v as _ServerQuery));

  @override
  _ServerQuery get _value => super._value as _ServerQuery;

  @override
  $Res call({
    Object? tags = freezed,
    Object? safeMode = freezed,
  }) {
    return _then(_ServerQuery(
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      safeMode: safeMode == freezed
          ? _value.safeMode
          : safeMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_ServerQuery with DiagnosticableTreeMixin implements _ServerQuery {
  const _$_ServerQuery({this.tags = '*', this.safeMode = true});

  @JsonKey(defaultValue: '*')
  @override
  final String tags;
  @JsonKey(defaultValue: true)
  @override
  final bool safeMode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ServerQuery(tags: $tags, safeMode: $safeMode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ServerQuery'))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('safeMode', safeMode));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ServerQuery &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)) &&
            (identical(other.safeMode, safeMode) ||
                const DeepCollectionEquality()
                    .equals(other.safeMode, safeMode)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(tags) ^
      const DeepCollectionEquality().hash(safeMode);

  @JsonKey(ignore: true)
  @override
  _$ServerQueryCopyWith<_ServerQuery> get copyWith =>
      __$ServerQueryCopyWithImpl<_ServerQuery>(this, _$identity);
}

abstract class _ServerQuery implements ServerQuery {
  const factory _ServerQuery({String tags, bool safeMode}) = _$_ServerQuery;

  @override
  String get tags => throw _privateConstructorUsedError;
  @override
  bool get safeMode => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$ServerQueryCopyWith<_ServerQuery> get copyWith =>
      throw _privateConstructorUsedError;
}
