// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'app_theme_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppThemeData {
  ThemeData get day => throw _privateConstructorUsedError;
  ThemeData get night => throw _privateConstructorUsedError;
  ThemeData get midnight => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppThemeDataCopyWith<AppThemeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppThemeDataCopyWith<$Res> {
  factory $AppThemeDataCopyWith(
          AppThemeData value, $Res Function(AppThemeData) then) =
      _$AppThemeDataCopyWithImpl<$Res>;
  $Res call({ThemeData day, ThemeData night, ThemeData midnight});
}

/// @nodoc
class _$AppThemeDataCopyWithImpl<$Res> implements $AppThemeDataCopyWith<$Res> {
  _$AppThemeDataCopyWithImpl(this._value, this._then);

  final AppThemeData _value;
  // ignore: unused_field
  final $Res Function(AppThemeData) _then;

  @override
  $Res call({
    Object? day = freezed,
    Object? night = freezed,
    Object? midnight = freezed,
  }) {
    return _then(_value.copyWith(
      day: day == freezed
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      night: night == freezed
          ? _value.night
          : night // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      midnight: midnight == freezed
          ? _value.midnight
          : midnight // ignore: cast_nullable_to_non_nullable
              as ThemeData,
    ));
  }
}

/// @nodoc
abstract class _$$_AppThemeDataCopyWith<$Res>
    implements $AppThemeDataCopyWith<$Res> {
  factory _$$_AppThemeDataCopyWith(
          _$_AppThemeData value, $Res Function(_$_AppThemeData) then) =
      __$$_AppThemeDataCopyWithImpl<$Res>;
  @override
  $Res call({ThemeData day, ThemeData night, ThemeData midnight});
}

/// @nodoc
class __$$_AppThemeDataCopyWithImpl<$Res>
    extends _$AppThemeDataCopyWithImpl<$Res>
    implements _$$_AppThemeDataCopyWith<$Res> {
  __$$_AppThemeDataCopyWithImpl(
      _$_AppThemeData _value, $Res Function(_$_AppThemeData) _then)
      : super(_value, (v) => _then(v as _$_AppThemeData));

  @override
  _$_AppThemeData get _value => super._value as _$_AppThemeData;

  @override
  $Res call({
    Object? day = freezed,
    Object? night = freezed,
    Object? midnight = freezed,
  }) {
    return _then(_$_AppThemeData(
      day: day == freezed
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      night: night == freezed
          ? _value.night
          : night // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      midnight: midnight == freezed
          ? _value.midnight
          : midnight // ignore: cast_nullable_to_non_nullable
              as ThemeData,
    ));
  }
}

/// @nodoc

class _$_AppThemeData extends _AppThemeData with DiagnosticableTreeMixin {
  const _$_AppThemeData(
      {required this.day, required this.night, required this.midnight})
      : super._();

  @override
  final ThemeData day;
  @override
  final ThemeData night;
  @override
  final ThemeData midnight;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppThemeData(day: $day, night: $night, midnight: $midnight)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppThemeData'))
      ..add(DiagnosticsProperty('day', day))
      ..add(DiagnosticsProperty('night', night))
      ..add(DiagnosticsProperty('midnight', midnight));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppThemeData &&
            const DeepCollectionEquality().equals(other.day, day) &&
            const DeepCollectionEquality().equals(other.night, night) &&
            const DeepCollectionEquality().equals(other.midnight, midnight));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(day),
      const DeepCollectionEquality().hash(night),
      const DeepCollectionEquality().hash(midnight));

  @JsonKey(ignore: true)
  @override
  _$$_AppThemeDataCopyWith<_$_AppThemeData> get copyWith =>
      __$$_AppThemeDataCopyWithImpl<_$_AppThemeData>(this, _$identity);
}

abstract class _AppThemeData extends AppThemeData {
  const factory _AppThemeData(
      {required final ThemeData day,
      required final ThemeData night,
      required final ThemeData midnight}) = _$_AppThemeData;
  const _AppThemeData._() : super._();

  @override
  ThemeData get day;
  @override
  ThemeData get night;
  @override
  ThemeData get midnight;
  @override
  @JsonKey(ignore: true)
  _$$_AppThemeDataCopyWith<_$_AppThemeData> get copyWith =>
      throw _privateConstructorUsedError;
}
