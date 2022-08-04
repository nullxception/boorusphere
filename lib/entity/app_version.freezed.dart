// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'app_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppVersion {
  int get major => throw _privateConstructorUsedError;
  int get minor => throw _privateConstructorUsedError;
  int get patch => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppVersionCopyWith<AppVersion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppVersionCopyWith<$Res> {
  factory $AppVersionCopyWith(
          AppVersion value, $Res Function(AppVersion) then) =
      _$AppVersionCopyWithImpl<$Res>;
  $Res call({int major, int minor, int patch});
}

/// @nodoc
class _$AppVersionCopyWithImpl<$Res> implements $AppVersionCopyWith<$Res> {
  _$AppVersionCopyWithImpl(this._value, this._then);

  final AppVersion _value;
  // ignore: unused_field
  final $Res Function(AppVersion) _then;

  @override
  $Res call({
    Object? major = freezed,
    Object? minor = freezed,
    Object? patch = freezed,
  }) {
    return _then(_value.copyWith(
      major: major == freezed
          ? _value.major
          : major // ignore: cast_nullable_to_non_nullable
              as int,
      minor: minor == freezed
          ? _value.minor
          : minor // ignore: cast_nullable_to_non_nullable
              as int,
      patch: patch == freezed
          ? _value.patch
          : patch // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$$_AppVersionCopyWith<$Res>
    implements $AppVersionCopyWith<$Res> {
  factory _$$_AppVersionCopyWith(
          _$_AppVersion value, $Res Function(_$_AppVersion) then) =
      __$$_AppVersionCopyWithImpl<$Res>;
  @override
  $Res call({int major, int minor, int patch});
}

/// @nodoc
class __$$_AppVersionCopyWithImpl<$Res> extends _$AppVersionCopyWithImpl<$Res>
    implements _$$_AppVersionCopyWith<$Res> {
  __$$_AppVersionCopyWithImpl(
      _$_AppVersion _value, $Res Function(_$_AppVersion) _then)
      : super(_value, (v) => _then(v as _$_AppVersion));

  @override
  _$_AppVersion get _value => super._value as _$_AppVersion;

  @override
  $Res call({
    Object? major = freezed,
    Object? minor = freezed,
    Object? patch = freezed,
  }) {
    return _then(_$_AppVersion(
      major: major == freezed
          ? _value.major
          : major // ignore: cast_nullable_to_non_nullable
              as int,
      minor: minor == freezed
          ? _value.minor
          : minor // ignore: cast_nullable_to_non_nullable
              as int,
      patch: patch == freezed
          ? _value.patch
          : patch // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_AppVersion extends _AppVersion {
  const _$_AppVersion({this.major = 0, this.minor = 0, this.patch = 0})
      : super._();

  @override
  @JsonKey()
  final int major;
  @override
  @JsonKey()
  final int minor;
  @override
  @JsonKey()
  final int patch;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppVersion &&
            const DeepCollectionEquality().equals(other.major, major) &&
            const DeepCollectionEquality().equals(other.minor, minor) &&
            const DeepCollectionEquality().equals(other.patch, patch));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(major),
      const DeepCollectionEquality().hash(minor),
      const DeepCollectionEquality().hash(patch));

  @JsonKey(ignore: true)
  @override
  _$$_AppVersionCopyWith<_$_AppVersion> get copyWith =>
      __$$_AppVersionCopyWithImpl<_$_AppVersion>(this, _$identity);
}

abstract class _AppVersion extends AppVersion {
  const factory _AppVersion(
      {final int major, final int minor, final int patch}) = _$_AppVersion;
  const _AppVersion._() : super._();

  @override
  int get major;
  @override
  int get minor;
  @override
  int get patch;
  @override
  @JsonKey(ignore: true)
  _$$_AppVersionCopyWith<_$_AppVersion> get copyWith =>
      throw _privateConstructorUsedError;
}
