// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'page_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PageOption {
  String get query => throw _privateConstructorUsedError;
  bool get clear => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PageOptionCopyWith<PageOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageOptionCopyWith<$Res> {
  factory $PageOptionCopyWith(
          PageOption value, $Res Function(PageOption) then) =
      _$PageOptionCopyWithImpl<$Res, PageOption>;
  @useResult
  $Res call({String query, bool clear});
}

/// @nodoc
class _$PageOptionCopyWithImpl<$Res, $Val extends PageOption>
    implements $PageOptionCopyWith<$Res> {
  _$PageOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? clear = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      clear: null == clear
          ? _value.clear
          : clear // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PageOptionCopyWith<$Res>
    implements $PageOptionCopyWith<$Res> {
  factory _$$_PageOptionCopyWith(
          _$_PageOption value, $Res Function(_$_PageOption) then) =
      __$$_PageOptionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String query, bool clear});
}

/// @nodoc
class __$$_PageOptionCopyWithImpl<$Res>
    extends _$PageOptionCopyWithImpl<$Res, _$_PageOption>
    implements _$$_PageOptionCopyWith<$Res> {
  __$$_PageOptionCopyWithImpl(
      _$_PageOption _value, $Res Function(_$_PageOption) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? clear = null,
  }) {
    return _then(_$_PageOption(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      clear: null == clear
          ? _value.clear
          : clear // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_PageOption extends _PageOption {
  const _$_PageOption({this.query = '', this.clear = false}) : super._();

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final bool clear;

  @override
  String toString() {
    return 'PageOption(query: $query, clear: $clear)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PageOption &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.clear, clear) || other.clear == clear));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, clear);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PageOptionCopyWith<_$_PageOption> get copyWith =>
      __$$_PageOptionCopyWithImpl<_$_PageOption>(this, _$identity);
}

abstract class _PageOption extends PageOption {
  const factory _PageOption({final String query, final bool clear}) =
      _$_PageOption;
  const _PageOption._() : super._();

  @override
  String get query;
  @override
  bool get clear;
  @override
  @JsonKey(ignore: true)
  _$$_PageOptionCopyWith<_$_PageOption> get copyWith =>
      throw _privateConstructorUsedError;
}
