// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'pixel_size.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PixelSize {
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PixelSizeCopyWith<PixelSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PixelSizeCopyWith<$Res> {
  factory $PixelSizeCopyWith(PixelSize value, $Res Function(PixelSize) then) =
      _$PixelSizeCopyWithImpl<$Res>;
  $Res call({int width, int height});
}

/// @nodoc
class _$PixelSizeCopyWithImpl<$Res> implements $PixelSizeCopyWith<$Res> {
  _$PixelSizeCopyWithImpl(this._value, this._then);

  final PixelSize _value;
  // ignore: unused_field
  final $Res Function(PixelSize) _then;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_value.copyWith(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$$_PixelSizeCopyWith<$Res> implements $PixelSizeCopyWith<$Res> {
  factory _$$_PixelSizeCopyWith(
          _$_PixelSize value, $Res Function(_$_PixelSize) then) =
      __$$_PixelSizeCopyWithImpl<$Res>;
  @override
  $Res call({int width, int height});
}

/// @nodoc
class __$$_PixelSizeCopyWithImpl<$Res> extends _$PixelSizeCopyWithImpl<$Res>
    implements _$$_PixelSizeCopyWith<$Res> {
  __$$_PixelSizeCopyWithImpl(
      _$_PixelSize _value, $Res Function(_$_PixelSize) _then)
      : super(_value, (v) => _then(v as _$_PixelSize));

  @override
  _$_PixelSize get _value => super._value as _$_PixelSize;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_$_PixelSize(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_PixelSize extends _PixelSize {
  const _$_PixelSize({this.width = -1, this.height = -1}) : super._();

  @override
  @JsonKey()
  final int width;
  @override
  @JsonKey()
  final int height;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PixelSize &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.height, height));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(height));

  @JsonKey(ignore: true)
  @override
  _$$_PixelSizeCopyWith<_$_PixelSize> get copyWith =>
      __$$_PixelSizeCopyWithImpl<_$_PixelSize>(this, _$identity);
}

abstract class _PixelSize extends PixelSize {
  const factory _PixelSize({final int width, final int height}) = _$_PixelSize;
  const _PixelSize._() : super._();

  @override
  int get width;
  @override
  int get height;
  @override
  @JsonKey(ignore: true)
  _$$_PixelSizeCopyWith<_$_PixelSize> get copyWith =>
      throw _privateConstructorUsedError;
}
