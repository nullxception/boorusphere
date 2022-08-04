// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'app_update_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppUpdateData {
  String get arch => throw _privateConstructorUsedError;
  AppVersion get currentVersion => throw _privateConstructorUsedError;
  AppVersion get newVersion => throw _privateConstructorUsedError;
  String get apkUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppUpdateDataCopyWith<AppUpdateData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUpdateDataCopyWith<$Res> {
  factory $AppUpdateDataCopyWith(
          AppUpdateData value, $Res Function(AppUpdateData) then) =
      _$AppUpdateDataCopyWithImpl<$Res>;
  $Res call(
      {String arch,
      AppVersion currentVersion,
      AppVersion newVersion,
      String apkUrl});

  $AppVersionCopyWith<$Res> get currentVersion;
  $AppVersionCopyWith<$Res> get newVersion;
}

/// @nodoc
class _$AppUpdateDataCopyWithImpl<$Res>
    implements $AppUpdateDataCopyWith<$Res> {
  _$AppUpdateDataCopyWithImpl(this._value, this._then);

  final AppUpdateData _value;
  // ignore: unused_field
  final $Res Function(AppUpdateData) _then;

  @override
  $Res call({
    Object? arch = freezed,
    Object? currentVersion = freezed,
    Object? newVersion = freezed,
    Object? apkUrl = freezed,
  }) {
    return _then(_value.copyWith(
      arch: arch == freezed
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String,
      currentVersion: currentVersion == freezed
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as AppVersion,
      newVersion: newVersion == freezed
          ? _value.newVersion
          : newVersion // ignore: cast_nullable_to_non_nullable
              as AppVersion,
      apkUrl: apkUrl == freezed
          ? _value.apkUrl
          : apkUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  @override
  $AppVersionCopyWith<$Res> get currentVersion {
    return $AppVersionCopyWith<$Res>(_value.currentVersion, (value) {
      return _then(_value.copyWith(currentVersion: value));
    });
  }

  @override
  $AppVersionCopyWith<$Res> get newVersion {
    return $AppVersionCopyWith<$Res>(_value.newVersion, (value) {
      return _then(_value.copyWith(newVersion: value));
    });
  }
}

/// @nodoc
abstract class _$$_AppUpdateDataCopyWith<$Res>
    implements $AppUpdateDataCopyWith<$Res> {
  factory _$$_AppUpdateDataCopyWith(
          _$_AppUpdateData value, $Res Function(_$_AppUpdateData) then) =
      __$$_AppUpdateDataCopyWithImpl<$Res>;
  @override
  $Res call(
      {String arch,
      AppVersion currentVersion,
      AppVersion newVersion,
      String apkUrl});

  @override
  $AppVersionCopyWith<$Res> get currentVersion;
  @override
  $AppVersionCopyWith<$Res> get newVersion;
}

/// @nodoc
class __$$_AppUpdateDataCopyWithImpl<$Res>
    extends _$AppUpdateDataCopyWithImpl<$Res>
    implements _$$_AppUpdateDataCopyWith<$Res> {
  __$$_AppUpdateDataCopyWithImpl(
      _$_AppUpdateData _value, $Res Function(_$_AppUpdateData) _then)
      : super(_value, (v) => _then(v as _$_AppUpdateData));

  @override
  _$_AppUpdateData get _value => super._value as _$_AppUpdateData;

  @override
  $Res call({
    Object? arch = freezed,
    Object? currentVersion = freezed,
    Object? newVersion = freezed,
    Object? apkUrl = freezed,
  }) {
    return _then(_$_AppUpdateData(
      arch: arch == freezed
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String,
      currentVersion: currentVersion == freezed
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as AppVersion,
      newVersion: newVersion == freezed
          ? _value.newVersion
          : newVersion // ignore: cast_nullable_to_non_nullable
              as AppVersion,
      apkUrl: apkUrl == freezed
          ? _value.apkUrl
          : apkUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_AppUpdateData extends _AppUpdateData {
  const _$_AppUpdateData(
      {this.arch = 'armeabi-v7a',
      this.currentVersion = AppVersion.zero,
      this.newVersion = AppVersion.zero,
      this.apkUrl = ''})
      : super._();

  @override
  @JsonKey()
  final String arch;
  @override
  @JsonKey()
  final AppVersion currentVersion;
  @override
  @JsonKey()
  final AppVersion newVersion;
  @override
  @JsonKey()
  final String apkUrl;

  @override
  String toString() {
    return 'AppUpdateData(arch: $arch, currentVersion: $currentVersion, newVersion: $newVersion, apkUrl: $apkUrl)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppUpdateData &&
            const DeepCollectionEquality().equals(other.arch, arch) &&
            const DeepCollectionEquality()
                .equals(other.currentVersion, currentVersion) &&
            const DeepCollectionEquality()
                .equals(other.newVersion, newVersion) &&
            const DeepCollectionEquality().equals(other.apkUrl, apkUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(arch),
      const DeepCollectionEquality().hash(currentVersion),
      const DeepCollectionEquality().hash(newVersion),
      const DeepCollectionEquality().hash(apkUrl));

  @JsonKey(ignore: true)
  @override
  _$$_AppUpdateDataCopyWith<_$_AppUpdateData> get copyWith =>
      __$$_AppUpdateDataCopyWithImpl<_$_AppUpdateData>(this, _$identity);
}

abstract class _AppUpdateData extends AppUpdateData {
  const factory _AppUpdateData(
      {final String arch,
      final AppVersion currentVersion,
      final AppVersion newVersion,
      final String apkUrl}) = _$_AppUpdateData;
  const _AppUpdateData._() : super._();

  @override
  String get arch;
  @override
  AppVersion get currentVersion;
  @override
  AppVersion get newVersion;
  @override
  String get apkUrl;
  @override
  @JsonKey(ignore: true)
  _$$_AppUpdateDataCopyWith<_$_AppUpdateData> get copyWith =>
      throw _privateConstructorUsedError;
}
