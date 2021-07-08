// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'booru_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$BooruPostTearOff {
  const _$BooruPostTearOff();

  _BooruPost call(
      {required int id,
      required String src,
      required String displaySrc,
      required String thumbnail,
      required List<String> tags,
      required int width,
      required int height}) {
    return _BooruPost(
      id: id,
      src: src,
      displaySrc: displaySrc,
      thumbnail: thumbnail,
      tags: tags,
      width: width,
      height: height,
    );
  }
}

/// @nodoc
const $BooruPost = _$BooruPostTearOff();

/// @nodoc
mixin _$BooruPost {
  int get id => throw _privateConstructorUsedError;
  String get src => throw _privateConstructorUsedError;
  String get displaySrc => throw _privateConstructorUsedError;
  String get thumbnail => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BooruPostCopyWith<BooruPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BooruPostCopyWith<$Res> {
  factory $BooruPostCopyWith(BooruPost value, $Res Function(BooruPost) then) =
      _$BooruPostCopyWithImpl<$Res>;
  $Res call(
      {int id,
      String src,
      String displaySrc,
      String thumbnail,
      List<String> tags,
      int width,
      int height});
}

/// @nodoc
class _$BooruPostCopyWithImpl<$Res> implements $BooruPostCopyWith<$Res> {
  _$BooruPostCopyWithImpl(this._value, this._then);

  final BooruPost _value;
  // ignore: unused_field
  final $Res Function(BooruPost) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? src = freezed,
    Object? displaySrc = freezed,
    Object? thumbnail = freezed,
    Object? tags = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      src: src == freezed
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String,
      displaySrc: displaySrc == freezed
          ? _value.displaySrc
          : displaySrc // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: thumbnail == freezed
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
abstract class _$BooruPostCopyWith<$Res> implements $BooruPostCopyWith<$Res> {
  factory _$BooruPostCopyWith(
          _BooruPost value, $Res Function(_BooruPost) then) =
      __$BooruPostCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      String src,
      String displaySrc,
      String thumbnail,
      List<String> tags,
      int width,
      int height});
}

/// @nodoc
class __$BooruPostCopyWithImpl<$Res> extends _$BooruPostCopyWithImpl<$Res>
    implements _$BooruPostCopyWith<$Res> {
  __$BooruPostCopyWithImpl(_BooruPost _value, $Res Function(_BooruPost) _then)
      : super(_value, (v) => _then(v as _BooruPost));

  @override
  _BooruPost get _value => super._value as _BooruPost;

  @override
  $Res call({
    Object? id = freezed,
    Object? src = freezed,
    Object? displaySrc = freezed,
    Object? thumbnail = freezed,
    Object? tags = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(_BooruPost(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      src: src == freezed
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String,
      displaySrc: displaySrc == freezed
          ? _value.displaySrc
          : displaySrc // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnail: thumbnail == freezed
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
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

class _$_BooruPost extends _BooruPost with DiagnosticableTreeMixin {
  const _$_BooruPost(
      {required this.id,
      required this.src,
      required this.displaySrc,
      required this.thumbnail,
      required this.tags,
      required this.width,
      required this.height})
      : super._();

  @override
  final int id;
  @override
  final String src;
  @override
  final String displaySrc;
  @override
  final String thumbnail;
  @override
  final List<String> tags;
  @override
  final int width;
  @override
  final int height;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BooruPost(id: $id, src: $src, displaySrc: $displaySrc, thumbnail: $thumbnail, tags: $tags, width: $width, height: $height)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BooruPost'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('src', src))
      ..add(DiagnosticsProperty('displaySrc', displaySrc))
      ..add(DiagnosticsProperty('thumbnail', thumbnail))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _BooruPost &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.src, src) ||
                const DeepCollectionEquality().equals(other.src, src)) &&
            (identical(other.displaySrc, displaySrc) ||
                const DeepCollectionEquality()
                    .equals(other.displaySrc, displaySrc)) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality()
                    .equals(other.thumbnail, thumbnail)) &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)) &&
            (identical(other.width, width) ||
                const DeepCollectionEquality().equals(other.width, width)) &&
            (identical(other.height, height) ||
                const DeepCollectionEquality().equals(other.height, height)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(src) ^
      const DeepCollectionEquality().hash(displaySrc) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(tags) ^
      const DeepCollectionEquality().hash(width) ^
      const DeepCollectionEquality().hash(height);

  @JsonKey(ignore: true)
  @override
  _$BooruPostCopyWith<_BooruPost> get copyWith =>
      __$BooruPostCopyWithImpl<_BooruPost>(this, _$identity);
}

abstract class _BooruPost extends BooruPost {
  const factory _BooruPost(
      {required int id,
      required String src,
      required String displaySrc,
      required String thumbnail,
      required List<String> tags,
      required int width,
      required int height}) = _$_BooruPost;
  const _BooruPost._() : super._();

  @override
  int get id => throw _privateConstructorUsedError;
  @override
  String get src => throw _privateConstructorUsedError;
  @override
  String get displaySrc => throw _privateConstructorUsedError;
  @override
  String get thumbnail => throw _privateConstructorUsedError;
  @override
  List<String> get tags => throw _privateConstructorUsedError;
  @override
  int get width => throw _privateConstructorUsedError;
  @override
  int get height => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$BooruPostCopyWith<_BooruPost> get copyWith =>
      throw _privateConstructorUsedError;
}
