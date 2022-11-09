// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'download_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DownloadEntry {
  @HiveField(0, defaultValue: '')
  String get id => throw _privateConstructorUsedError;
  @HiveField(1, defaultValue: Post.empty)
  Post get post => throw _privateConstructorUsedError;
  @HiveField(2, defaultValue: '')
  String get destination => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DownloadEntryCopyWith<DownloadEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadEntryCopyWith<$Res> {
  factory $DownloadEntryCopyWith(
          DownloadEntry value, $Res Function(DownloadEntry) then) =
      _$DownloadEntryCopyWithImpl<$Res, DownloadEntry>;
  @useResult
  $Res call(
      {@HiveField(0, defaultValue: '') String id,
      @HiveField(1, defaultValue: Post.empty) Post post,
      @HiveField(2, defaultValue: '') String destination});

  $PostCopyWith<$Res> get post;
}

/// @nodoc
class _$DownloadEntryCopyWithImpl<$Res, $Val extends DownloadEntry>
    implements $DownloadEntryCopyWith<$Res> {
  _$DownloadEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? post = null,
    Object? destination = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as Post,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PostCopyWith<$Res> get post {
    return $PostCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_DownloadEntryCopyWith<$Res>
    implements $DownloadEntryCopyWith<$Res> {
  factory _$$_DownloadEntryCopyWith(
          _$_DownloadEntry value, $Res Function(_$_DownloadEntry) then) =
      __$$_DownloadEntryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0, defaultValue: '') String id,
      @HiveField(1, defaultValue: Post.empty) Post post,
      @HiveField(2, defaultValue: '') String destination});

  @override
  $PostCopyWith<$Res> get post;
}

/// @nodoc
class __$$_DownloadEntryCopyWithImpl<$Res>
    extends _$DownloadEntryCopyWithImpl<$Res, _$_DownloadEntry>
    implements _$$_DownloadEntryCopyWith<$Res> {
  __$$_DownloadEntryCopyWithImpl(
      _$_DownloadEntry _value, $Res Function(_$_DownloadEntry) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? post = null,
    Object? destination = null,
  }) {
    return _then(_$_DownloadEntry(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as Post,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@HiveType(typeId: 4, adapterName: 'DownloadEntryAdapter')
class _$_DownloadEntry extends _DownloadEntry {
  const _$_DownloadEntry(
      {@HiveField(0, defaultValue: '') this.id = '',
      @HiveField(1, defaultValue: Post.empty) this.post = Post.empty,
      @HiveField(2, defaultValue: '') this.destination = ''})
      : super._();

  @override
  @JsonKey()
  @HiveField(0, defaultValue: '')
  final String id;
  @override
  @JsonKey()
  @HiveField(1, defaultValue: Post.empty)
  final Post post;
  @override
  @JsonKey()
  @HiveField(2, defaultValue: '')
  final String destination;

  @override
  String toString() {
    return 'DownloadEntry(id: $id, post: $post, destination: $destination)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DownloadEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.destination, destination) ||
                other.destination == destination));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, post, destination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DownloadEntryCopyWith<_$_DownloadEntry> get copyWith =>
      __$$_DownloadEntryCopyWithImpl<_$_DownloadEntry>(this, _$identity);
}

abstract class _DownloadEntry extends DownloadEntry {
  const factory _DownloadEntry(
          {@HiveField(0, defaultValue: '') final String id,
          @HiveField(1, defaultValue: Post.empty) final Post post,
          @HiveField(2, defaultValue: '') final String destination}) =
      _$_DownloadEntry;
  const _DownloadEntry._() : super._();

  @override
  @HiveField(0, defaultValue: '')
  String get id;
  @override
  @HiveField(1, defaultValue: Post.empty)
  Post get post;
  @override
  @HiveField(2, defaultValue: '')
  String get destination;
  @override
  @JsonKey(ignore: true)
  _$$_DownloadEntryCopyWith<_$_DownloadEntry> get copyWith =>
      throw _privateConstructorUsedError;
}
