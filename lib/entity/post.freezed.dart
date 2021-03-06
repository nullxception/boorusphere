// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Post {
  @HiveField(0, defaultValue: -1)
  int get id => throw _privateConstructorUsedError;
  @HiveField(1, defaultValue: '')
  String get originalFile => throw _privateConstructorUsedError;
  @HiveField(2, defaultValue: '')
  String get sampleFile => throw _privateConstructorUsedError;
  @HiveField(3, defaultValue: '')
  String get previewFile => throw _privateConstructorUsedError;
  @HiveField(4, defaultValue: [])
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(5, defaultValue: -1)
  int get width => throw _privateConstructorUsedError;
  @HiveField(6, defaultValue: -1)
  int get height => throw _privateConstructorUsedError;
  @HiveField(7, defaultValue: '')
  String get serverName => throw _privateConstructorUsedError;
  @HiveField(8, defaultValue: '')
  String get postUrl => throw _privateConstructorUsedError;
  @HiveField(9, defaultValue: 'q')
  String get rateValue => throw _privateConstructorUsedError;
  @HiveField(10, defaultValue: -1)
  int get sampleWidth => throw _privateConstructorUsedError;
  @HiveField(11, defaultValue: -1)
  int get sampleHeight => throw _privateConstructorUsedError;
  @HiveField(12, defaultValue: -1)
  int get previewWidth => throw _privateConstructorUsedError;
  @HiveField(13, defaultValue: -1)
  int get previewHeight => throw _privateConstructorUsedError;
  @HiveField(14, defaultValue: '')
  String get source => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res>;
  $Res call(
      {@HiveField(0, defaultValue: -1) int id,
      @HiveField(1, defaultValue: '') String originalFile,
      @HiveField(2, defaultValue: '') String sampleFile,
      @HiveField(3, defaultValue: '') String previewFile,
      @HiveField(4, defaultValue: []) List<String> tags,
      @HiveField(5, defaultValue: -1) int width,
      @HiveField(6, defaultValue: -1) int height,
      @HiveField(7, defaultValue: '') String serverName,
      @HiveField(8, defaultValue: '') String postUrl,
      @HiveField(9, defaultValue: 'q') String rateValue,
      @HiveField(10, defaultValue: -1) int sampleWidth,
      @HiveField(11, defaultValue: -1) int sampleHeight,
      @HiveField(12, defaultValue: -1) int previewWidth,
      @HiveField(13, defaultValue: -1) int previewHeight,
      @HiveField(14, defaultValue: '') String source});
}

/// @nodoc
class _$PostCopyWithImpl<$Res> implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  final Post _value;
  // ignore: unused_field
  final $Res Function(Post) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? originalFile = freezed,
    Object? sampleFile = freezed,
    Object? previewFile = freezed,
    Object? tags = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? serverName = freezed,
    Object? postUrl = freezed,
    Object? rateValue = freezed,
    Object? sampleWidth = freezed,
    Object? sampleHeight = freezed,
    Object? previewWidth = freezed,
    Object? previewHeight = freezed,
    Object? source = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      originalFile: originalFile == freezed
          ? _value.originalFile
          : originalFile // ignore: cast_nullable_to_non_nullable
              as String,
      sampleFile: sampleFile == freezed
          ? _value.sampleFile
          : sampleFile // ignore: cast_nullable_to_non_nullable
              as String,
      previewFile: previewFile == freezed
          ? _value.previewFile
          : previewFile // ignore: cast_nullable_to_non_nullable
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
      postUrl: postUrl == freezed
          ? _value.postUrl
          : postUrl // ignore: cast_nullable_to_non_nullable
              as String,
      rateValue: rateValue == freezed
          ? _value.rateValue
          : rateValue // ignore: cast_nullable_to_non_nullable
              as String,
      sampleWidth: sampleWidth == freezed
          ? _value.sampleWidth
          : sampleWidth // ignore: cast_nullable_to_non_nullable
              as int,
      sampleHeight: sampleHeight == freezed
          ? _value.sampleHeight
          : sampleHeight // ignore: cast_nullable_to_non_nullable
              as int,
      previewWidth: previewWidth == freezed
          ? _value.previewWidth
          : previewWidth // ignore: cast_nullable_to_non_nullable
              as int,
      previewHeight: previewHeight == freezed
          ? _value.previewHeight
          : previewHeight // ignore: cast_nullable_to_non_nullable
              as int,
      source: source == freezed
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$_PostCopyWith(_$_Post value, $Res Function(_$_Post) then) =
      __$$_PostCopyWithImpl<$Res>;
  @override
  $Res call(
      {@HiveField(0, defaultValue: -1) int id,
      @HiveField(1, defaultValue: '') String originalFile,
      @HiveField(2, defaultValue: '') String sampleFile,
      @HiveField(3, defaultValue: '') String previewFile,
      @HiveField(4, defaultValue: []) List<String> tags,
      @HiveField(5, defaultValue: -1) int width,
      @HiveField(6, defaultValue: -1) int height,
      @HiveField(7, defaultValue: '') String serverName,
      @HiveField(8, defaultValue: '') String postUrl,
      @HiveField(9, defaultValue: 'q') String rateValue,
      @HiveField(10, defaultValue: -1) int sampleWidth,
      @HiveField(11, defaultValue: -1) int sampleHeight,
      @HiveField(12, defaultValue: -1) int previewWidth,
      @HiveField(13, defaultValue: -1) int previewHeight,
      @HiveField(14, defaultValue: '') String source});
}

/// @nodoc
class __$$_PostCopyWithImpl<$Res> extends _$PostCopyWithImpl<$Res>
    implements _$$_PostCopyWith<$Res> {
  __$$_PostCopyWithImpl(_$_Post _value, $Res Function(_$_Post) _then)
      : super(_value, (v) => _then(v as _$_Post));

  @override
  _$_Post get _value => super._value as _$_Post;

  @override
  $Res call({
    Object? id = freezed,
    Object? originalFile = freezed,
    Object? sampleFile = freezed,
    Object? previewFile = freezed,
    Object? tags = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? serverName = freezed,
    Object? postUrl = freezed,
    Object? rateValue = freezed,
    Object? sampleWidth = freezed,
    Object? sampleHeight = freezed,
    Object? previewWidth = freezed,
    Object? previewHeight = freezed,
    Object? source = freezed,
  }) {
    return _then(_$_Post(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      originalFile: originalFile == freezed
          ? _value.originalFile
          : originalFile // ignore: cast_nullable_to_non_nullable
              as String,
      sampleFile: sampleFile == freezed
          ? _value.sampleFile
          : sampleFile // ignore: cast_nullable_to_non_nullable
              as String,
      previewFile: previewFile == freezed
          ? _value.previewFile
          : previewFile // ignore: cast_nullable_to_non_nullable
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
      postUrl: postUrl == freezed
          ? _value.postUrl
          : postUrl // ignore: cast_nullable_to_non_nullable
              as String,
      rateValue: rateValue == freezed
          ? _value.rateValue
          : rateValue // ignore: cast_nullable_to_non_nullable
              as String,
      sampleWidth: sampleWidth == freezed
          ? _value.sampleWidth
          : sampleWidth // ignore: cast_nullable_to_non_nullable
              as int,
      sampleHeight: sampleHeight == freezed
          ? _value.sampleHeight
          : sampleHeight // ignore: cast_nullable_to_non_nullable
              as int,
      previewWidth: previewWidth == freezed
          ? _value.previewWidth
          : previewWidth // ignore: cast_nullable_to_non_nullable
              as int,
      previewHeight: previewHeight == freezed
          ? _value.previewHeight
          : previewHeight // ignore: cast_nullable_to_non_nullable
              as int,
      source: source == freezed
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@HiveType(typeId: 3, adapterName: 'PostAdapter')
class _$_Post extends _Post with DiagnosticableTreeMixin {
  const _$_Post(
      {@HiveField(0, defaultValue: -1) required this.id,
      @HiveField(1, defaultValue: '') required this.originalFile,
      @HiveField(2, defaultValue: '') required this.sampleFile,
      @HiveField(3, defaultValue: '') required this.previewFile,
      @HiveField(4, defaultValue: []) required final List<String> tags,
      @HiveField(5, defaultValue: -1) required this.width,
      @HiveField(6, defaultValue: -1) required this.height,
      @HiveField(7, defaultValue: '') required this.serverName,
      @HiveField(8, defaultValue: '') required this.postUrl,
      @HiveField(9, defaultValue: 'q') this.rateValue = 'q',
      @HiveField(10, defaultValue: -1) this.sampleWidth = -1,
      @HiveField(11, defaultValue: -1) this.sampleHeight = -1,
      @HiveField(12, defaultValue: -1) this.previewWidth = -1,
      @HiveField(13, defaultValue: -1) this.previewHeight = -1,
      @HiveField(14, defaultValue: '') this.source = ''})
      : _tags = tags,
        super._();

  @override
  @HiveField(0, defaultValue: -1)
  final int id;
  @override
  @HiveField(1, defaultValue: '')
  final String originalFile;
  @override
  @HiveField(2, defaultValue: '')
  final String sampleFile;
  @override
  @HiveField(3, defaultValue: '')
  final String previewFile;
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
  @HiveField(8, defaultValue: '')
  final String postUrl;
  @override
  @JsonKey()
  @HiveField(9, defaultValue: 'q')
  final String rateValue;
  @override
  @JsonKey()
  @HiveField(10, defaultValue: -1)
  final int sampleWidth;
  @override
  @JsonKey()
  @HiveField(11, defaultValue: -1)
  final int sampleHeight;
  @override
  @JsonKey()
  @HiveField(12, defaultValue: -1)
  final int previewWidth;
  @override
  @JsonKey()
  @HiveField(13, defaultValue: -1)
  final int previewHeight;
  @override
  @JsonKey()
  @HiveField(14, defaultValue: '')
  final String source;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Post(id: $id, originalFile: $originalFile, sampleFile: $sampleFile, previewFile: $previewFile, tags: $tags, width: $width, height: $height, serverName: $serverName, postUrl: $postUrl, rateValue: $rateValue, sampleWidth: $sampleWidth, sampleHeight: $sampleHeight, previewWidth: $previewWidth, previewHeight: $previewHeight, source: $source)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Post'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('originalFile', originalFile))
      ..add(DiagnosticsProperty('sampleFile', sampleFile))
      ..add(DiagnosticsProperty('previewFile', previewFile))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('serverName', serverName))
      ..add(DiagnosticsProperty('postUrl', postUrl))
      ..add(DiagnosticsProperty('rateValue', rateValue))
      ..add(DiagnosticsProperty('sampleWidth', sampleWidth))
      ..add(DiagnosticsProperty('sampleHeight', sampleHeight))
      ..add(DiagnosticsProperty('previewWidth', previewWidth))
      ..add(DiagnosticsProperty('previewHeight', previewHeight))
      ..add(DiagnosticsProperty('source', source));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Post &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality()
                .equals(other.originalFile, originalFile) &&
            const DeepCollectionEquality()
                .equals(other.sampleFile, sampleFile) &&
            const DeepCollectionEquality()
                .equals(other.previewFile, previewFile) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality()
                .equals(other.serverName, serverName) &&
            const DeepCollectionEquality().equals(other.postUrl, postUrl) &&
            const DeepCollectionEquality().equals(other.rateValue, rateValue) &&
            const DeepCollectionEquality()
                .equals(other.sampleWidth, sampleWidth) &&
            const DeepCollectionEquality()
                .equals(other.sampleHeight, sampleHeight) &&
            const DeepCollectionEquality()
                .equals(other.previewWidth, previewWidth) &&
            const DeepCollectionEquality()
                .equals(other.previewHeight, previewHeight) &&
            const DeepCollectionEquality().equals(other.source, source));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(originalFile),
      const DeepCollectionEquality().hash(sampleFile),
      const DeepCollectionEquality().hash(previewFile),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(serverName),
      const DeepCollectionEquality().hash(postUrl),
      const DeepCollectionEquality().hash(rateValue),
      const DeepCollectionEquality().hash(sampleWidth),
      const DeepCollectionEquality().hash(sampleHeight),
      const DeepCollectionEquality().hash(previewWidth),
      const DeepCollectionEquality().hash(previewHeight),
      const DeepCollectionEquality().hash(source));

  @JsonKey(ignore: true)
  @override
  _$$_PostCopyWith<_$_Post> get copyWith =>
      __$$_PostCopyWithImpl<_$_Post>(this, _$identity);
}

abstract class _Post extends Post {
  const factory _Post(
      {@HiveField(0, defaultValue: -1) required final int id,
      @HiveField(1, defaultValue: '') required final String originalFile,
      @HiveField(2, defaultValue: '') required final String sampleFile,
      @HiveField(3, defaultValue: '') required final String previewFile,
      @HiveField(4, defaultValue: []) required final List<String> tags,
      @HiveField(5, defaultValue: -1) required final int width,
      @HiveField(6, defaultValue: -1) required final int height,
      @HiveField(7, defaultValue: '') required final String serverName,
      @HiveField(8, defaultValue: '') required final String postUrl,
      @HiveField(9, defaultValue: 'q') final String rateValue,
      @HiveField(10, defaultValue: -1) final int sampleWidth,
      @HiveField(11, defaultValue: -1) final int sampleHeight,
      @HiveField(12, defaultValue: -1) final int previewWidth,
      @HiveField(13, defaultValue: -1) final int previewHeight,
      @HiveField(14, defaultValue: '') final String source}) = _$_Post;
  const _Post._() : super._();

  @override
  @HiveField(0, defaultValue: -1)
  int get id;
  @override
  @HiveField(1, defaultValue: '')
  String get originalFile;
  @override
  @HiveField(2, defaultValue: '')
  String get sampleFile;
  @override
  @HiveField(3, defaultValue: '')
  String get previewFile;
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
  @HiveField(8, defaultValue: '')
  String get postUrl;
  @override
  @HiveField(9, defaultValue: 'q')
  String get rateValue;
  @override
  @HiveField(10, defaultValue: -1)
  int get sampleWidth;
  @override
  @HiveField(11, defaultValue: -1)
  int get sampleHeight;
  @override
  @HiveField(12, defaultValue: -1)
  int get previewWidth;
  @override
  @HiveField(13, defaultValue: -1)
  int get previewHeight;
  @override
  @HiveField(14, defaultValue: '')
  String get source;
  @override
  @JsonKey(ignore: true)
  _$$_PostCopyWith<_$_Post> get copyWith => throw _privateConstructorUsedError;
}
