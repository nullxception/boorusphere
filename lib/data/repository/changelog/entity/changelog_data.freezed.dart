// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'changelog_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ChangelogData {
  AppVersion get version => throw _privateConstructorUsedError;
  List<String> get logs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChangelogDataCopyWith<ChangelogData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangelogDataCopyWith<$Res> {
  factory $ChangelogDataCopyWith(
          ChangelogData value, $Res Function(ChangelogData) then) =
      _$ChangelogDataCopyWithImpl<$Res, ChangelogData>;
  @useResult
  $Res call({AppVersion version, List<String> logs});

  $AppVersionCopyWith<$Res> get version;
}

/// @nodoc
class _$ChangelogDataCopyWithImpl<$Res, $Val extends ChangelogData>
    implements $ChangelogDataCopyWith<$Res> {
  _$ChangelogDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? logs = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as AppVersion,
      logs: null == logs
          ? _value.logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AppVersionCopyWith<$Res> get version {
    return $AppVersionCopyWith<$Res>(_value.version, (value) {
      return _then(_value.copyWith(version: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_ChangelogDataCopyWith<$Res>
    implements $ChangelogDataCopyWith<$Res> {
  factory _$$_ChangelogDataCopyWith(
          _$_ChangelogData value, $Res Function(_$_ChangelogData) then) =
      __$$_ChangelogDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppVersion version, List<String> logs});

  @override
  $AppVersionCopyWith<$Res> get version;
}

/// @nodoc
class __$$_ChangelogDataCopyWithImpl<$Res>
    extends _$ChangelogDataCopyWithImpl<$Res, _$_ChangelogData>
    implements _$$_ChangelogDataCopyWith<$Res> {
  __$$_ChangelogDataCopyWithImpl(
      _$_ChangelogData _value, $Res Function(_$_ChangelogData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? logs = null,
  }) {
    return _then(_$_ChangelogData(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as AppVersion,
      logs: null == logs
          ? _value._logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$_ChangelogData extends _ChangelogData {
  const _$_ChangelogData(
      {this.version = AppVersion.zero, final List<String> logs = const []})
      : _logs = logs,
        super._();

  @override
  @JsonKey()
  final AppVersion version;
  final List<String> _logs;
  @override
  @JsonKey()
  List<String> get logs {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  @override
  String toString() {
    return 'ChangelogData(version: $version, logs: $logs)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChangelogData &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._logs, _logs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, version, const DeepCollectionEquality().hash(_logs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChangelogDataCopyWith<_$_ChangelogData> get copyWith =>
      __$$_ChangelogDataCopyWithImpl<_$_ChangelogData>(this, _$identity);
}

abstract class _ChangelogData extends ChangelogData {
  const factory _ChangelogData(
      {final AppVersion version, final List<String> logs}) = _$_ChangelogData;
  const _ChangelogData._() : super._();

  @override
  AppVersion get version;
  @override
  List<String> get logs;
  @override
  @JsonKey(ignore: true)
  _$$_ChangelogDataCopyWith<_$_ChangelogData> get copyWith =>
      throw _privateConstructorUsedError;
}
