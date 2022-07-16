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
  @HiveField(0, defaultValue: -1)
  int get id => throw _privateConstructorUsedError;
  @HiveField(1, defaultValue: '')
  String get src => throw _privateConstructorUsedError;
  @HiveField(2, defaultValue: '')
  String get displaySrc => throw _privateConstructorUsedError;
  @HiveField(3, defaultValue: '')
  String get thumbnail => throw _privateConstructorUsedError;
  @HiveField(4, defaultValue: [])
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(5, defaultValue: -1)
  int get width => throw _privateConstructorUsedError;
  @HiveField(6, defaultValue: -1)
  int get height => throw _privateConstructorUsedError;
  @HiveField(7, defaultValue: '')
  String get serverName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BooruPostCopyWith<BooruPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BooruPostCopyWith<$Res> {
  factory $BooruPostCopyWith(BooruPost value, $Res Function(BooruPost) then) =
      _$BooruPostCopyWithImpl<$Res>;
  $Res call(
      {@HiveField(0, defaultValue: -1) int id,
      @HiveField(1, defaultValue: '') String src,
      @HiveField(2, defaultValue: '') String displaySrc,
      @HiveField(3, defaultValue: '') String thumbnail,
      @HiveField(4, defaultValue: []) List<String> tags,
      @HiveField(5, defaultValue: -1) int width,
      @HiveField(6, defaultValue: -1) int height,
      @HiveField(7, defaultValue: '') String serverName});
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
    Object? serverName = freezed,
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
      serverName: serverName == freezed
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
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
      {@HiveField(0, defaultValue: -1) int id,
      @HiveField(1, defaultValue: '') String src,
      @HiveField(2, defaultValue: '') String displaySrc,
      @HiveField(3, defaultValue: '') String thumbnail,
      @HiveField(4, defaultValue: []) List<String> tags,
      @HiveField(5, defaultValue: -1) int width,
      @HiveField(6, defaultValue: -1) int height,
      @HiveField(7, defaultValue: '') String serverName});
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
    Object? serverName = freezed,
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
      serverName: serverName == freezed
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@HiveType(typeId: 3, adapterName: 'BooruPostAdapter')
class _$_BooruPost extends _BooruPost with DiagnosticableTreeMixin {
  const _$_BooruPost(
      {@HiveField(0, defaultValue: -1) required this.id,
      @HiveField(1, defaultValue: '') required this.src,
      @HiveField(2, defaultValue: '') required this.displaySrc,
      @HiveField(3, defaultValue: '') required this.thumbnail,
      @HiveField(4, defaultValue: []) required final List<String> tags,
      @HiveField(5, defaultValue: -1) required this.width,
      @HiveField(6, defaultValue: -1) required this.height,
      @HiveField(7, defaultValue: '') required this.serverName})
      : _tags = tags,
        super._();

  @override
  @HiveField(0, defaultValue: -1)
  final int id;
  @override
  @HiveField(1, defaultValue: '')
  final String src;
  @override
  @HiveField(2, defaultValue: '')
  final String displaySrc;
  @override
  @HiveField(3, defaultValue: '')
  final String thumbnail;
  final List<String> _tags;
  @override
  @HiveField(4, defaultValue: [])
  List<String> get tags {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @HiveField(5, defaultValue: -1)
  final int width;
  @override
  @HiveField(6, defaultValue: -1)
  final int height;
  @override
  @HiveField(7, defaultValue: '')
  final String serverName;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BooruPost(id: $id, src: $src, displaySrc: $displaySrc, thumbnail: $thumbnail, tags: $tags, width: $width, height: $height, serverName: $serverName)';
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
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('serverName', serverName));
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
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality()
                .equals(other.serverName, serverName));
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
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(serverName));

  @JsonKey(ignore: true)
  @override
  _$$_BooruPostCopyWith<_$_BooruPost> get copyWith =>
      __$$_BooruPostCopyWithImpl<_$_BooruPost>(this, _$identity);
}

abstract class _BooruPost extends BooruPost {
  const factory _BooruPost(
          {@HiveField(0, defaultValue: -1) required final int id,
          @HiveField(1, defaultValue: '') required final String src,
          @HiveField(2, defaultValue: '') required final String displaySrc,
          @HiveField(3, defaultValue: '') required final String thumbnail,
          @HiveField(4, defaultValue: []) required final List<String> tags,
          @HiveField(5, defaultValue: -1) required final int width,
          @HiveField(6, defaultValue: -1) required final int height,
          @HiveField(7, defaultValue: '') required final String serverName}) =
      _$_BooruPost;
  const _BooruPost._() : super._();

  @override
  @HiveField(0, defaultValue: -1)
  int get id;
  @override
  @HiveField(1, defaultValue: '')
  String get src;
  @override
  @HiveField(2, defaultValue: '')
  String get displaySrc;
  @override
  @HiveField(3, defaultValue: '')
  String get thumbnail;
  @override
  @HiveField(4, defaultValue: [])
  List<String> get tags;
  @override
  @HiveField(5, defaultValue: -1)
  int get width;
  @override
  @HiveField(6, defaultValue: -1)
  int get height;
  @override
  @HiveField(7, defaultValue: '')
  String get serverName;
  @override
  @JsonKey(ignore: true)
  _$$_BooruPostCopyWith<_$_BooruPost> get copyWith =>
      throw _privateConstructorUsedError;
}
