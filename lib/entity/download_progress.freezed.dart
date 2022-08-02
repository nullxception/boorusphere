// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'download_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DownloadProgress {
  String get id => throw _privateConstructorUsedError;
  DownloadStatus get status => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DownloadProgressCopyWith<DownloadProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadProgressCopyWith<$Res> {
  factory $DownloadProgressCopyWith(
          DownloadProgress value, $Res Function(DownloadProgress) then) =
      _$DownloadProgressCopyWithImpl<$Res>;
  $Res call({String id, DownloadStatus status, int progress, int timestamp});
}

/// @nodoc
class _$DownloadProgressCopyWithImpl<$Res>
    implements $DownloadProgressCopyWith<$Res> {
  _$DownloadProgressCopyWithImpl(this._value, this._then);

  final DownloadProgress _value;
  // ignore: unused_field
  final $Res Function(DownloadProgress) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? status = freezed,
    Object? progress = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      progress: progress == freezed
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: timestamp == freezed
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$$_DownloadProgressCopyWith<$Res>
    implements $DownloadProgressCopyWith<$Res> {
  factory _$$_DownloadProgressCopyWith(
          _$_DownloadProgress value, $Res Function(_$_DownloadProgress) then) =
      __$$_DownloadProgressCopyWithImpl<$Res>;
  @override
  $Res call({String id, DownloadStatus status, int progress, int timestamp});
}

/// @nodoc
class __$$_DownloadProgressCopyWithImpl<$Res>
    extends _$DownloadProgressCopyWithImpl<$Res>
    implements _$$_DownloadProgressCopyWith<$Res> {
  __$$_DownloadProgressCopyWithImpl(
      _$_DownloadProgress _value, $Res Function(_$_DownloadProgress) _then)
      : super(_value, (v) => _then(v as _$_DownloadProgress));

  @override
  _$_DownloadProgress get _value => super._value as _$_DownloadProgress;

  @override
  $Res call({
    Object? id = freezed,
    Object? status = freezed,
    Object? progress = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_$_DownloadProgress(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: status == freezed
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      progress: progress == freezed
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: timestamp == freezed
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_DownloadProgress implements _DownloadProgress {
  const _$_DownloadProgress(
      {required this.id,
      required this.status,
      required this.progress,
      required this.timestamp});

  @override
  final String id;
  @override
  final DownloadStatus status;
  @override
  final int progress;
  @override
  final int timestamp;

  @override
  String toString() {
    return 'DownloadProgress(id: $id, status: $status, progress: $progress, timestamp: $timestamp)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DownloadProgress &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.status, status) &&
            const DeepCollectionEquality().equals(other.progress, progress) &&
            const DeepCollectionEquality().equals(other.timestamp, timestamp));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(status),
      const DeepCollectionEquality().hash(progress),
      const DeepCollectionEquality().hash(timestamp));

  @JsonKey(ignore: true)
  @override
  _$$_DownloadProgressCopyWith<_$_DownloadProgress> get copyWith =>
      __$$_DownloadProgressCopyWithImpl<_$_DownloadProgress>(this, _$identity);
}

abstract class _DownloadProgress implements DownloadProgress {
  const factory _DownloadProgress(
      {required final String id,
      required final DownloadStatus status,
      required final int progress,
      required final int timestamp}) = _$_DownloadProgress;

  @override
  String get id;
  @override
  DownloadStatus get status;
  @override
  int get progress;
  @override
  int get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$_DownloadProgressCopyWith<_$_DownloadProgress> get copyWith =>
      throw _privateConstructorUsedError;
}
