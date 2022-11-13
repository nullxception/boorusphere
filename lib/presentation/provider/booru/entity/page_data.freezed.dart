// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'page_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PageData {
  PageOption get option => throw _privateConstructorUsedError;
  List<Post> get posts => throw _privateConstructorUsedError;
  List<Cookie> get cookies => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PageDataCopyWith<PageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageDataCopyWith<$Res> {
  factory $PageDataCopyWith(PageData value, $Res Function(PageData) then) =
      _$PageDataCopyWithImpl<$Res, PageData>;
  @useResult
  $Res call({PageOption option, List<Post> posts, List<Cookie> cookies});

  $PageOptionCopyWith<$Res> get option;
}

/// @nodoc
class _$PageDataCopyWithImpl<$Res, $Val extends PageData>
    implements $PageDataCopyWith<$Res> {
  _$PageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? option = null,
    Object? posts = null,
    Object? cookies = null,
  }) {
    return _then(_value.copyWith(
      option: null == option
          ? _value.option
          : option // ignore: cast_nullable_to_non_nullable
              as PageOption,
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<Post>,
      cookies: null == cookies
          ? _value.cookies
          : cookies // ignore: cast_nullable_to_non_nullable
              as List<Cookie>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PageOptionCopyWith<$Res> get option {
    return $PageOptionCopyWith<$Res>(_value.option, (value) {
      return _then(_value.copyWith(option: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_PageDataCopyWith<$Res> implements $PageDataCopyWith<$Res> {
  factory _$$_PageDataCopyWith(
          _$_PageData value, $Res Function(_$_PageData) then) =
      __$$_PageDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PageOption option, List<Post> posts, List<Cookie> cookies});

  @override
  $PageOptionCopyWith<$Res> get option;
}

/// @nodoc
class __$$_PageDataCopyWithImpl<$Res>
    extends _$PageDataCopyWithImpl<$Res, _$_PageData>
    implements _$$_PageDataCopyWith<$Res> {
  __$$_PageDataCopyWithImpl(
      _$_PageData _value, $Res Function(_$_PageData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? option = null,
    Object? posts = null,
    Object? cookies = null,
  }) {
    return _then(_$_PageData(
      option: null == option
          ? _value.option
          : option // ignore: cast_nullable_to_non_nullable
              as PageOption,
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<Post>,
      cookies: null == cookies
          ? _value._cookies
          : cookies // ignore: cast_nullable_to_non_nullable
              as List<Cookie>,
    ));
  }
}

/// @nodoc

class _$_PageData implements _PageData {
  const _$_PageData(
      {this.option = const PageOption(clear: true),
      final List<Post> posts = const <Post>[],
      final List<Cookie> cookies = const <Cookie>[]})
      : _posts = posts,
        _cookies = cookies;

  @override
  @JsonKey()
  final PageOption option;
  final List<Post> _posts;
  @override
  @JsonKey()
  List<Post> get posts {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  final List<Cookie> _cookies;
  @override
  @JsonKey()
  List<Cookie> get cookies {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cookies);
  }

  @override
  String toString() {
    return 'PageData(option: $option, posts: $posts, cookies: $cookies)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PageData &&
            (identical(other.option, option) || other.option == option) &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            const DeepCollectionEquality().equals(other._cookies, _cookies));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      option,
      const DeepCollectionEquality().hash(_posts),
      const DeepCollectionEquality().hash(_cookies));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PageDataCopyWith<_$_PageData> get copyWith =>
      __$$_PageDataCopyWithImpl<_$_PageData>(this, _$identity);
}

abstract class _PageData implements PageData {
  const factory _PageData(
      {final PageOption option,
      final List<Post> posts,
      final List<Cookie> cookies}) = _$_PageData;

  @override
  PageOption get option;
  @override
  List<Post> get posts;
  @override
  List<Cookie> get cookies;
  @override
  @JsonKey(ignore: true)
  _$$_PageDataCopyWith<_$_PageData> get copyWith =>
      throw _privateConstructorUsedError;
}
