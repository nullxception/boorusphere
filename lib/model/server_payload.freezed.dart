// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'server_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$ServerPayloadTearOff {
  const _$ServerPayloadTearOff();

  _ServerPayload call(
      {String host = '',
      String? query,
      ServerPayloadType type = ServerPayloadType.search}) {
    return _ServerPayload(
      host: host,
      query: query,
      type: type,
    );
  }
}

/// @nodoc
const $ServerPayload = _$ServerPayloadTearOff();

/// @nodoc
mixin _$ServerPayload {
  String get host => throw _privateConstructorUsedError;
  String? get query => throw _privateConstructorUsedError;
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
  $Res call({String host, String? query, ServerPayloadType type});
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
              as String?,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ServerPayloadType,
    ));
  }
}

/// @nodoc
abstract class _$ServerPayloadCopyWith<$Res>
    implements $ServerPayloadCopyWith<$Res> {
  factory _$ServerPayloadCopyWith(
          _ServerPayload value, $Res Function(_ServerPayload) then) =
      __$ServerPayloadCopyWithImpl<$Res>;
  @override
  $Res call({String host, String? query, ServerPayloadType type});
}

/// @nodoc
class __$ServerPayloadCopyWithImpl<$Res>
    extends _$ServerPayloadCopyWithImpl<$Res>
    implements _$ServerPayloadCopyWith<$Res> {
  __$ServerPayloadCopyWithImpl(
      _ServerPayload _value, $Res Function(_ServerPayload) _then)
      : super(_value, (v) => _then(v as _ServerPayload));

  @override
  _ServerPayload get _value => super._value as _ServerPayload;

  @override
  $Res call({
    Object? host = freezed,
    Object? query = freezed,
    Object? type = freezed,
  }) {
    return _then(_ServerPayload(
      host: host == freezed
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      query: query == freezed
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
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
      {this.host = '', this.query, this.type = ServerPayloadType.search});

  @JsonKey(defaultValue: '')
  @override
  final String host;
  @override
  final String? query;
  @JsonKey(defaultValue: ServerPayloadType.search)
  @override
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
        (other is _ServerPayload &&
            (identical(other.host, host) ||
                const DeepCollectionEquality().equals(other.host, host)) &&
            (identical(other.query, query) ||
                const DeepCollectionEquality().equals(other.query, query)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(host) ^
      const DeepCollectionEquality().hash(query) ^
      const DeepCollectionEquality().hash(type);

  @JsonKey(ignore: true)
  @override
  _$ServerPayloadCopyWith<_ServerPayload> get copyWith =>
      __$ServerPayloadCopyWithImpl<_ServerPayload>(this, _$identity);
}

abstract class _ServerPayload implements ServerPayload {
  const factory _ServerPayload(
      {String host, String? query, ServerPayloadType type}) = _$_ServerPayload;

  @override
  String get host => throw _privateConstructorUsedError;
  @override
  String? get query => throw _privateConstructorUsedError;
  @override
  ServerPayloadType get type => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$ServerPayloadCopyWith<_ServerPayload> get copyWith =>
      throw _privateConstructorUsedError;
}
