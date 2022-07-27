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
      _$DownloadEntryCopyWithImpl<$Res>;
  $Res call(
      {@HiveField(0, defaultValue: '') String id,
      @HiveField(1, defaultValue: Post.empty) Post post,
      @HiveField(2, defaultValue: '') String destination});

  $PostCopyWith<$Res> get post;
}

/// @nodoc
class _$DownloadEntryCopyWithImpl<$Res>
    implements $DownloadEntryCopyWith<$Res> {
  _$DownloadEntryCopyWithImpl(this._value, this._then);

  final DownloadEntry _value;
  // ignore: unused_field
  final $Res Function(DownloadEntry) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? post = freezed,
    Object? destination = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      post: post == freezed
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as Post,
      destination: destination == freezed
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  @override
  $PostCopyWith<$Res> get post {
    return $PostCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value));
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
  $Res call(
      {@HiveField(0, defaultValue: '') String id,
      @HiveField(1, defaultValue: Post.empty) Post post,
      @HiveField(2, defaultValue: '') String destination});

  @override
  $PostCopyWith<$Res> get post;
}

/// @nodoc
class __$$_DownloadEntryCopyWithImpl<$Res>
    extends _$DownloadEntryCopyWithImpl<$Res>
    implements _$$_DownloadEntryCopyWith<$Res> {
  __$$_DownloadEntryCopyWithImpl(
      _$_DownloadEntry _value, $Res Function(_$_DownloadEntry) _then)
      : super(_value, (v) => _then(v as _$_DownloadEntry));

  @override
  _$_DownloadEntry get _value => super._value as _$_DownloadEntry;

  @override
  $Res call({
    Object? id = freezed,
    Object? post = freezed,
    Object? destination = freezed,
  }) {
    return _then(_$_DownloadEntry(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      post: post == freezed
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as Post,
      destination: destination == freezed
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@HiveType(typeId: 4, adapterName: 'DownloadEntryAdapter')
class _$_DownloadEntry extends _DownloadEntry with DiagnosticableTreeMixin {
  const _$_DownloadEntry(
      {@HiveField(0, defaultValue: '') required this.id,
      @HiveField(1, defaultValue: Post.empty) required this.post,
      @HiveField(2, defaultValue: '') required this.destination})
      : super._();

  @override
  @HiveField(0, defaultValue: '')
  final String id;
  @override
  @HiveField(1, defaultValue: Post.empty)
  final Post post;
  @override
  @HiveField(2, defaultValue: '')
  final String destination;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DownloadEntry(id: $id, post: $post, destination: $destination)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DownloadEntry'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('post', post))
      ..add(DiagnosticsProperty('destination', destination));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DownloadEntry &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.post, post) &&
            const DeepCollectionEquality()
                .equals(other.destination, destination));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(post),
      const DeepCollectionEquality().hash(destination));

  @JsonKey(ignore: true)
  @override
  _$$_DownloadEntryCopyWith<_$_DownloadEntry> get copyWith =>
      __$$_DownloadEntryCopyWithImpl<_$_DownloadEntry>(this, _$identity);
}

abstract class _DownloadEntry extends DownloadEntry {
  const factory _DownloadEntry(
          {@HiveField(0, defaultValue: '') required final String id,
          @HiveField(1, defaultValue: Post.empty) required final Post post,
          @HiveField(2, defaultValue: '') required final String destination}) =
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
