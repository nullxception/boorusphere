// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'booru_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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
abstract class _$$_BooruPostCopyWith<$Res> implements $BooruPostCopyWith<$Res> {
  factory _$$_BooruPostCopyWith(
          _$_BooruPost value, $Res Function(_$_BooruPost) then) =
      __$$_BooruPostCopyWithImpl<$Res>;
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
class __$$_BooruPostCopyWithImpl<$Res> extends _$BooruPostCopyWithImpl<$Res>
    implements _$$_BooruPostCopyWith<$Res> {
  __$$_BooruPostCopyWithImpl(
      _$_BooruPost _value, $Res Function(_$_BooruPost) _then)
      : super(_value, (v) => _then(v as _$_BooruPost));

  @override
  _$_BooruPost get _value => super._value as _$_BooruPost;

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
    return _then(_$_BooruPost(
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
          ? _value._tags
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
      required final List<String> tags,
      required this.width,
      required this.height})
      : _tags = tags,
        super._();

  @override
  final int id;
  @override
  final String src;
  @override
  final String displaySrc;
  @override
  final String thumbnail;
  final List<String> _tags;
  @override
  List<String> get tags {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

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
        (other.runtimeType == runtimeType &&
            other is _$_BooruPost &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.src, src) &&
            const DeepCollectionEquality()
                .equals(other.displaySrc, displaySrc) &&
            const DeepCollectionEquality().equals(other.thumbnail, thumbnail) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.height, height));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(src),
      const DeepCollectionEquality().hash(displaySrc),
      const DeepCollectionEquality().hash(thumbnail),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(height));

  @JsonKey(ignore: true)
  @override
  _$$_BooruPostCopyWith<_$_BooruPost> get copyWith =>
      __$$_BooruPostCopyWithImpl<_$_BooruPost>(this, _$identity);
}

abstract class _BooruPost extends BooruPost {
  const factory _BooruPost(
      {required final int id,
      required final String src,
      required final String displaySrc,
      required final String thumbnail,
      required final List<String> tags,
      required final int width,
      required final int height}) = _$_BooruPost;
  const _BooruPost._() : super._();

  @override
  int get id;
  @override
  String get src;
  @override
  String get displaySrc;
  @override
  String get thumbnail;
  @override
  List<String> get tags;
  @override
  int get width;
  @override
  int get height;
  @override
  @JsonKey(ignore: true)
  _$$_BooruPostCopyWith<_$_BooruPost> get copyWith =>
      throw _privateConstructorUsedError;
}
