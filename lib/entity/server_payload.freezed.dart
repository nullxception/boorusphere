// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'server_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ServerPayload {
  String get host => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  ServerPayloadType get type => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ServerPayloadCopyWith<ServerPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerPayloadCopyWith<$Res> {
  factory $ServerPayloadCopyWith(
          ServerPayload value, $Res Function(ServerPayload) then) =
      _$ServerPayloadCopyWithImpl<$Res>;
  $Res call({String host, String query, ServerPayloadType type});
}

/// @nodoc
class _$ServerPayloadCopyWithImpl<$Res>
    implements $ServerPayloadCopyWith<$Res> {
  _$ServerPayloadCopyWithImpl(this._value, this._then);

  final ServerPayload _value;
  // ignore: unused_field
  final $Res Function(ServerPayload) _then;

  @override
  $Res call({
    Object? host = freezed,
    Object? query = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      host: host == freezed
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      query: query == freezed
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ServerPayloadType,
    ));
  }
}

/// @nodoc
abstract class _$$_ServerPayloadCopyWith<$Res>
    implements $ServerPayloadCopyWith<$Res> {
  factory _$$_ServerPayloadCopyWith(
          _$_ServerPayload value, $Res Function(_$_ServerPayload) then) =
      __$$_ServerPayloadCopyWithImpl<$Res>;
  @override
  $Res call({String host, String query, ServerPayloadType type});
}

/// @nodoc
class __$$_ServerPayloadCopyWithImpl<$Res>
    extends _$ServerPayloadCopyWithImpl<$Res>
    implements _$$_ServerPayloadCopyWith<$Res> {
  __$$_ServerPayloadCopyWithImpl(
      _$_ServerPayload _value, $Res Function(_$_ServerPayload) _then)
      : super(_value, (v) => _then(v as _$_ServerPayload));

  @override
  _$_ServerPayload get _value => super._value as _$_ServerPayload;

  @override
  $Res call({
    Object? host = freezed,
    Object? query = freezed,
    Object? type = freezed,
  }) {
    return _then(_$_ServerPayload(
      host: host == freezed
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      query: query == freezed
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ServerPayloadType,
    ));
  }
}

/// @nodoc

class _$_ServerPayload with DiagnosticableTreeMixin implements _ServerPayload {
  const _$_ServerPayload(
      {this.host = '', this.query = '', this.type = ServerPayloadType.search});

  @override
  @JsonKey()
  final String host;
  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final ServerPayloadType type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ServerPayload(host: $host, query: $query, type: $type)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ServerPayload'))
      ..add(DiagnosticsProperty('host', host))
      ..add(DiagnosticsProperty('query', query))
      ..add(DiagnosticsProperty('type', type));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ServerPayload &&
            const DeepCollectionEquality().equals(other.host, host) &&
            const DeepCollectionEquality().equals(other.query, query) &&
            const DeepCollectionEquality().equals(other.type, type));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(host),
      const DeepCollectionEquality().hash(query),
      const DeepCollectionEquality().hash(type));

  @JsonKey(ignore: true)
  @override
  _$$_ServerPayloadCopyWith<_$_ServerPayload> get copyWith =>
      __$$_ServerPayloadCopyWithImpl<_$_ServerPayload>(this, _$identity);
}

abstract class _ServerPayload implements ServerPayload {
  const factory _ServerPayload(
      {final String host,
      final String query,
      final ServerPayloadType type}) = _$_ServerPayload;

  @override
  String get host;
  @override
  String get query;
  @override
  ServerPayloadType get type;
  @override
  @JsonKey(ignore: true)
  _$$_ServerPayloadCopyWith<_$_ServerPayload> get copyWith =>
      throw _privateConstructorUsedError;
}
