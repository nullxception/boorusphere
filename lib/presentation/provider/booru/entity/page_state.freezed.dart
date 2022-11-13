// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PageState {
  PageData get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PageData data) data,
    required TResult Function(PageData data) loading,
    required TResult Function(
            PageData data, Object error, StackTrace? stackTrace)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PageData data)? data,
    TResult? Function(PageData data)? loading,
    TResult? Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PageData data)? data,
    TResult Function(PageData data)? loading,
    TResult Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataPageState value) data,
    required TResult Function(LoadingPageState value) loading,
    required TResult Function(ErrorPageState value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataPageState value)? data,
    TResult? Function(LoadingPageState value)? loading,
    TResult? Function(ErrorPageState value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataPageState value)? data,
    TResult Function(LoadingPageState value)? loading,
    TResult Function(ErrorPageState value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PageStateCopyWith<PageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageStateCopyWith<$Res> {
  factory $PageStateCopyWith(PageState value, $Res Function(PageState) then) =
      _$PageStateCopyWithImpl<$Res, PageState>;
  @useResult
  $Res call({PageData data});

  $PageDataCopyWith<$Res> get data;
}

/// @nodoc
class _$PageStateCopyWithImpl<$Res, $Val extends PageState>
    implements $PageStateCopyWith<$Res> {
  _$PageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PageData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PageDataCopyWith<$Res> get data {
    return $PageDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DataPageStateCopyWith<$Res>
    implements $PageStateCopyWith<$Res> {
  factory _$$DataPageStateCopyWith(
          _$DataPageState value, $Res Function(_$DataPageState) then) =
      __$$DataPageStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PageData data});

  @override
  $PageDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$DataPageStateCopyWithImpl<$Res>
    extends _$PageStateCopyWithImpl<$Res, _$DataPageState>
    implements _$$DataPageStateCopyWith<$Res> {
  __$$DataPageStateCopyWithImpl(
      _$DataPageState _value, $Res Function(_$DataPageState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$DataPageState(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PageData,
    ));
  }
}

/// @nodoc

class _$DataPageState implements DataPageState {
  const _$DataPageState(this.data);

  @override
  final PageData data;

  @override
  String toString() {
    return 'PageState.data(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataPageState &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataPageStateCopyWith<_$DataPageState> get copyWith =>
      __$$DataPageStateCopyWithImpl<_$DataPageState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PageData data) data,
    required TResult Function(PageData data) loading,
    required TResult Function(
            PageData data, Object error, StackTrace? stackTrace)
        error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PageData data)? data,
    TResult? Function(PageData data)? loading,
    TResult? Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PageData data)? data,
    TResult Function(PageData data)? loading,
    TResult Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataPageState value) data,
    required TResult Function(LoadingPageState value) loading,
    required TResult Function(ErrorPageState value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataPageState value)? data,
    TResult? Function(LoadingPageState value)? loading,
    TResult? Function(ErrorPageState value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataPageState value)? data,
    TResult Function(LoadingPageState value)? loading,
    TResult Function(ErrorPageState value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class DataPageState implements PageState {
  const factory DataPageState(final PageData data) = _$DataPageState;

  @override
  PageData get data;
  @override
  @JsonKey(ignore: true)
  _$$DataPageStateCopyWith<_$DataPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadingPageStateCopyWith<$Res>
    implements $PageStateCopyWith<$Res> {
  factory _$$LoadingPageStateCopyWith(
          _$LoadingPageState value, $Res Function(_$LoadingPageState) then) =
      __$$LoadingPageStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PageData data});

  @override
  $PageDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$LoadingPageStateCopyWithImpl<$Res>
    extends _$PageStateCopyWithImpl<$Res, _$LoadingPageState>
    implements _$$LoadingPageStateCopyWith<$Res> {
  __$$LoadingPageStateCopyWithImpl(
      _$LoadingPageState _value, $Res Function(_$LoadingPageState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$LoadingPageState(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PageData,
    ));
  }
}

/// @nodoc

class _$LoadingPageState implements LoadingPageState {
  const _$LoadingPageState(this.data);

  @override
  final PageData data;

  @override
  String toString() {
    return 'PageState.loading(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadingPageState &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadingPageStateCopyWith<_$LoadingPageState> get copyWith =>
      __$$LoadingPageStateCopyWithImpl<_$LoadingPageState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PageData data) data,
    required TResult Function(PageData data) loading,
    required TResult Function(
            PageData data, Object error, StackTrace? stackTrace)
        error,
  }) {
    return loading(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PageData data)? data,
    TResult? Function(PageData data)? loading,
    TResult? Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
  }) {
    return loading?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PageData data)? data,
    TResult Function(PageData data)? loading,
    TResult Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataPageState value) data,
    required TResult Function(LoadingPageState value) loading,
    required TResult Function(ErrorPageState value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataPageState value)? data,
    TResult? Function(LoadingPageState value)? loading,
    TResult? Function(ErrorPageState value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataPageState value)? data,
    TResult Function(LoadingPageState value)? loading,
    TResult Function(ErrorPageState value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class LoadingPageState implements PageState {
  const factory LoadingPageState(final PageData data) = _$LoadingPageState;

  @override
  PageData get data;
  @override
  @JsonKey(ignore: true)
  _$$LoadingPageStateCopyWith<_$LoadingPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorPageStateCopyWith<$Res>
    implements $PageStateCopyWith<$Res> {
  factory _$$ErrorPageStateCopyWith(
          _$ErrorPageState value, $Res Function(_$ErrorPageState) then) =
      __$$ErrorPageStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PageData data, Object error, StackTrace? stackTrace});

  @override
  $PageDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ErrorPageStateCopyWithImpl<$Res>
    extends _$PageStateCopyWithImpl<$Res, _$ErrorPageState>
    implements _$$ErrorPageStateCopyWith<$Res> {
  __$$ErrorPageStateCopyWithImpl(
      _$ErrorPageState _value, $Res Function(_$ErrorPageState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? error = null,
    Object? stackTrace = freezed,
  }) {
    return _then(_$ErrorPageState(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PageData,
      null == error ? _value.error : error,
      freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$ErrorPageState implements ErrorPageState {
  const _$ErrorPageState(this.data, this.error, this.stackTrace);

  @override
  final PageData data;
  @override
  final Object error;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'PageState.error(data: $data, error: $error, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorPageState &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data,
      const DeepCollectionEquality().hash(error), stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorPageStateCopyWith<_$ErrorPageState> get copyWith =>
      __$$ErrorPageStateCopyWithImpl<_$ErrorPageState>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PageData data) data,
    required TResult Function(PageData data) loading,
    required TResult Function(
            PageData data, Object error, StackTrace? stackTrace)
        error,
  }) {
    return error(this.data, this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PageData data)? data,
    TResult? Function(PageData data)? loading,
    TResult? Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
  }) {
    return error?.call(this.data, this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PageData data)? data,
    TResult Function(PageData data)? loading,
    TResult Function(PageData data, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.data, this.error, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataPageState value) data,
    required TResult Function(LoadingPageState value) loading,
    required TResult Function(ErrorPageState value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataPageState value)? data,
    TResult? Function(LoadingPageState value)? loading,
    TResult? Function(ErrorPageState value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataPageState value)? data,
    TResult Function(LoadingPageState value)? loading,
    TResult Function(ErrorPageState value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorPageState implements PageState {
  const factory ErrorPageState(final PageData data, final Object error,
      final StackTrace? stackTrace) = _$ErrorPageState;

  @override
  PageData get data;
  Object get error;
  StackTrace? get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$ErrorPageStateCopyWith<_$ErrorPageState> get copyWith =>
      throw _privateConstructorUsedError;
}
