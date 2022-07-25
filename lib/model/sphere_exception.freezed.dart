// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'sphere_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SphereException {
  String get message => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SphereExceptionCopyWith<SphereException> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SphereExceptionCopyWith<$Res> {
  factory $SphereExceptionCopyWith(
          SphereException value, $Res Function(SphereException) then) =
      _$SphereExceptionCopyWithImpl<$Res>;
  $Res call({String message});
}

/// @nodoc
class _$SphereExceptionCopyWithImpl<$Res>
    implements $SphereExceptionCopyWith<$Res> {
  _$SphereExceptionCopyWithImpl(this._value, this._then);

  final SphereException _value;
  // ignore: unused_field
  final $Res Function(SphereException) _then;

  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      message: message == freezed
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_SphereExceptionCopyWith<$Res>
    implements $SphereExceptionCopyWith<$Res> {
  factory _$$_SphereExceptionCopyWith(
          _$_SphereException value, $Res Function(_$_SphereException) then) =
      __$$_SphereExceptionCopyWithImpl<$Res>;
  @override
  $Res call({String message});
}

/// @nodoc
class __$$_SphereExceptionCopyWithImpl<$Res>
    extends _$SphereExceptionCopyWithImpl<$Res>
    implements _$$_SphereExceptionCopyWith<$Res> {
  __$$_SphereExceptionCopyWithImpl(
      _$_SphereException _value, $Res Function(_$_SphereException) _then)
      : super(_value, (v) => _then(v as _$_SphereException));

  @override
  _$_SphereException get _value => super._value as _$_SphereException;

  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$_SphereException(
      message: message == freezed
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_SphereException implements _SphereException {
  const _$_SphereException({required this.message});

  @override
  final String message;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SphereException &&
            const DeepCollectionEquality().equals(other.message, message));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(message));

  @JsonKey(ignore: true)
  @override
  _$$_SphereExceptionCopyWith<_$_SphereException> get copyWith =>
      __$$_SphereExceptionCopyWithImpl<_$_SphereException>(this, _$identity);
}

abstract class _SphereException implements SphereException {
  const factory _SphereException({required final String message}) =
      _$_SphereException;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$_SphereExceptionCopyWith<_$_SphereException> get copyWith =>
      throw _privateConstructorUsedError;
}
