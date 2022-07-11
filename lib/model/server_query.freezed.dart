// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'server_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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
abstract class _$$_ServerQueryCopyWith<$Res>
    implements $ServerQueryCopyWith<$Res> {
  factory _$$_ServerQueryCopyWith(
          _$_ServerQuery value, $Res Function(_$_ServerQuery) then) =
      __$$_ServerQueryCopyWithImpl<$Res>;
  @override
  $Res call({String tags, bool safeMode});
}

/// @nodoc
class __$$_ServerQueryCopyWithImpl<$Res> extends _$ServerQueryCopyWithImpl<$Res>
    implements _$$_ServerQueryCopyWith<$Res> {
  __$$_ServerQueryCopyWithImpl(
      _$_ServerQuery _value, $Res Function(_$_ServerQuery) _then)
      : super(_value, (v) => _then(v as _$_ServerQuery));

  @override
  _$_ServerQuery get _value => super._value as _$_ServerQuery;

  @override
  $Res call({
    Object? tags = freezed,
    Object? safeMode = freezed,
  }) {
    return _then(_$_ServerQuery(
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

  @override
  @JsonKey()
  final String tags;
  @override
  @JsonKey()
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
        (other.runtimeType == runtimeType &&
            other is _$_ServerQuery &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.safeMode, safeMode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(safeMode));

  @JsonKey(ignore: true)
  @override
  _$$_ServerQueryCopyWith<_$_ServerQuery> get copyWith =>
      __$$_ServerQueryCopyWithImpl<_$_ServerQuery>(this, _$identity);
}

abstract class _ServerQuery implements ServerQuery {
  const factory _ServerQuery({final String tags, final bool safeMode}) =
      _$_ServerQuery;

  @override
  String get tags;
  @override
  bool get safeMode;
  @override
  @JsonKey(ignore: true)
  _$$_ServerQueryCopyWith<_$_ServerQuery> get copyWith =>
      throw _privateConstructorUsedError;
}
