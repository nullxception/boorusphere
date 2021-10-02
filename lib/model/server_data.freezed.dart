// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'server_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ServerData _$ServerDataFromJson(Map<String, dynamic> json) {
  return _ServerData.fromJson(json);
}

/// @nodoc
class _$ServerDataTearOff {
  const _$ServerDataTearOff();

  _ServerData call(
      {@HiveField(0, defaultValue: '') required String name,
      @HiveField(1, defaultValue: '') required String homepage,
      @HiveField(2, defaultValue: '') String? postUrl,
      @HiveField(3, defaultValue: '') required String searchUrl,
      @HiveField(7, defaultValue: '') String? tagSuggestionUrl}) {
    return _ServerData(
      name: name,
      homepage: homepage,
      postUrl: postUrl,
      searchUrl: searchUrl,
      tagSuggestionUrl: tagSuggestionUrl,
    );
  }

  ServerData fromJson(Map<String, Object> json) {
    return ServerData.fromJson(json);
  }
}

/// @nodoc
const $ServerData = _$ServerDataTearOff();

/// @nodoc
mixin _$ServerData {
  @HiveField(0, defaultValue: '')
  String get name => throw _privateConstructorUsedError;
  @HiveField(1, defaultValue: '')
  String get homepage => throw _privateConstructorUsedError;
  @HiveField(2, defaultValue: '')
  String? get postUrl => throw _privateConstructorUsedError;
  @HiveField(3, defaultValue: '')
  String get searchUrl => throw _privateConstructorUsedError;
  @HiveField(7, defaultValue: '')
  String? get tagSuggestionUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerDataCopyWith<ServerData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerDataCopyWith<$Res> {
  factory $ServerDataCopyWith(
          ServerData value, $Res Function(ServerData) then) =
      _$ServerDataCopyWithImpl<$Res>;
  $Res call(
      {@HiveField(0, defaultValue: '') String name,
      @HiveField(1, defaultValue: '') String homepage,
      @HiveField(2, defaultValue: '') String? postUrl,
      @HiveField(3, defaultValue: '') String searchUrl,
      @HiveField(7, defaultValue: '') String? tagSuggestionUrl});
}

/// @nodoc
class _$ServerDataCopyWithImpl<$Res> implements $ServerDataCopyWith<$Res> {
  _$ServerDataCopyWithImpl(this._value, this._then);

  final ServerData _value;
  // ignore: unused_field
  final $Res Function(ServerData) _then;

  @override
  $Res call({
    Object? name = freezed,
    Object? homepage = freezed,
    Object? postUrl = freezed,
    Object? searchUrl = freezed,
    Object? tagSuggestionUrl = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      homepage: homepage == freezed
          ? _value.homepage
          : homepage // ignore: cast_nullable_to_non_nullable
              as String,
      postUrl: postUrl == freezed
          ? _value.postUrl
          : postUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      searchUrl: searchUrl == freezed
          ? _value.searchUrl
          : searchUrl // ignore: cast_nullable_to_non_nullable
              as String,
      tagSuggestionUrl: tagSuggestionUrl == freezed
          ? _value.tagSuggestionUrl
          : tagSuggestionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$ServerDataCopyWith<$Res> implements $ServerDataCopyWith<$Res> {
  factory _$ServerDataCopyWith(
          _ServerData value, $Res Function(_ServerData) then) =
      __$ServerDataCopyWithImpl<$Res>;
  @override
  $Res call(
      {@HiveField(0, defaultValue: '') String name,
      @HiveField(1, defaultValue: '') String homepage,
      @HiveField(2, defaultValue: '') String? postUrl,
      @HiveField(3, defaultValue: '') String searchUrl,
      @HiveField(7, defaultValue: '') String? tagSuggestionUrl});
}

/// @nodoc
class __$ServerDataCopyWithImpl<$Res> extends _$ServerDataCopyWithImpl<$Res>
    implements _$ServerDataCopyWith<$Res> {
  __$ServerDataCopyWithImpl(
      _ServerData _value, $Res Function(_ServerData) _then)
      : super(_value, (v) => _then(v as _ServerData));

  @override
  _ServerData get _value => super._value as _ServerData;

  @override
  $Res call({
    Object? name = freezed,
    Object? homepage = freezed,
    Object? postUrl = freezed,
    Object? searchUrl = freezed,
    Object? tagSuggestionUrl = freezed,
  }) {
    return _then(_ServerData(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      homepage: homepage == freezed
          ? _value.homepage
          : homepage // ignore: cast_nullable_to_non_nullable
              as String,
      postUrl: postUrl == freezed
          ? _value.postUrl
          : postUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      searchUrl: searchUrl == freezed
          ? _value.searchUrl
          : searchUrl // ignore: cast_nullable_to_non_nullable
              as String,
      tagSuggestionUrl: tagSuggestionUrl == freezed
          ? _value.tagSuggestionUrl
          : tagSuggestionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 2, adapterName: 'ServersAdapter')
class _$_ServerData extends _ServerData with DiagnosticableTreeMixin {
  const _$_ServerData(
      {@HiveField(0, defaultValue: '') required this.name,
      @HiveField(1, defaultValue: '') required this.homepage,
      @HiveField(2, defaultValue: '') this.postUrl,
      @HiveField(3, defaultValue: '') required this.searchUrl,
      @HiveField(7, defaultValue: '') this.tagSuggestionUrl})
      : super._();

  factory _$_ServerData.fromJson(Map<String, dynamic> json) =>
      _$$_ServerDataFromJson(json);

  @override
  @HiveField(0, defaultValue: '')
  final String name;
  @override
  @HiveField(1, defaultValue: '')
  final String homepage;
  @override
  @HiveField(2, defaultValue: '')
  final String? postUrl;
  @override
  @HiveField(3, defaultValue: '')
  final String searchUrl;
  @override
  @HiveField(7, defaultValue: '')
  final String? tagSuggestionUrl;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ServerData(name: $name, homepage: $homepage, postUrl: $postUrl, searchUrl: $searchUrl, tagSuggestionUrl: $tagSuggestionUrl)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ServerData'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('homepage', homepage))
      ..add(DiagnosticsProperty('postUrl', postUrl))
      ..add(DiagnosticsProperty('searchUrl', searchUrl))
      ..add(DiagnosticsProperty('tagSuggestionUrl', tagSuggestionUrl));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ServerData &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.homepage, homepage) ||
                const DeepCollectionEquality()
                    .equals(other.homepage, homepage)) &&
            (identical(other.postUrl, postUrl) ||
                const DeepCollectionEquality()
                    .equals(other.postUrl, postUrl)) &&
            (identical(other.searchUrl, searchUrl) ||
                const DeepCollectionEquality()
                    .equals(other.searchUrl, searchUrl)) &&
            (identical(other.tagSuggestionUrl, tagSuggestionUrl) ||
                const DeepCollectionEquality()
                    .equals(other.tagSuggestionUrl, tagSuggestionUrl)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(homepage) ^
      const DeepCollectionEquality().hash(postUrl) ^
      const DeepCollectionEquality().hash(searchUrl) ^
      const DeepCollectionEquality().hash(tagSuggestionUrl);

  @JsonKey(ignore: true)
  @override
  _$ServerDataCopyWith<_ServerData> get copyWith =>
      __$ServerDataCopyWithImpl<_ServerData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ServerDataToJson(this);
  }
}

abstract class _ServerData extends ServerData {
  const factory _ServerData(
          {@HiveField(0, defaultValue: '') required String name,
          @HiveField(1, defaultValue: '') required String homepage,
          @HiveField(2, defaultValue: '') String? postUrl,
          @HiveField(3, defaultValue: '') required String searchUrl,
          @HiveField(7, defaultValue: '') String? tagSuggestionUrl}) =
      _$_ServerData;
  const _ServerData._() : super._();

  factory _ServerData.fromJson(Map<String, dynamic> json) =
      _$_ServerData.fromJson;

  @override
  @HiveField(0, defaultValue: '')
  String get name => throw _privateConstructorUsedError;
  @override
  @HiveField(1, defaultValue: '')
  String get homepage => throw _privateConstructorUsedError;
  @override
  @HiveField(2, defaultValue: '')
  String? get postUrl => throw _privateConstructorUsedError;
  @override
  @HiveField(3, defaultValue: '')
  String get searchUrl => throw _privateConstructorUsedError;
  @override
  @HiveField(7, defaultValue: '')
  String? get tagSuggestionUrl => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$ServerDataCopyWith<_ServerData> get copyWith =>
      throw _privateConstructorUsedError;
}
