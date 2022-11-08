// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'search_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SearchHistory {
  @HiveField(0, defaultValue: '')
  String get query => throw _privateConstructorUsedError;
  @HiveField(1, defaultValue: '')
  String get server => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchHistoryCopyWith<SearchHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchHistoryCopyWith<$Res> {
  factory $SearchHistoryCopyWith(
          SearchHistory value, $Res Function(SearchHistory) then) =
      _$SearchHistoryCopyWithImpl<$Res, SearchHistory>;
  @useResult
  $Res call(
      {@HiveField(0, defaultValue: '') String query,
      @HiveField(1, defaultValue: '') String server});
}

/// @nodoc
class _$SearchHistoryCopyWithImpl<$Res, $Val extends SearchHistory>
    implements $SearchHistoryCopyWith<$Res> {
  _$SearchHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? server = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      server: null == server
          ? _value.server
          : server // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SearchHistoryCopyWith<$Res>
    implements $SearchHistoryCopyWith<$Res> {
  factory _$$_SearchHistoryCopyWith(
          _$_SearchHistory value, $Res Function(_$_SearchHistory) then) =
      __$$_SearchHistoryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0, defaultValue: '') String query,
      @HiveField(1, defaultValue: '') String server});
}

/// @nodoc
class __$$_SearchHistoryCopyWithImpl<$Res>
    extends _$SearchHistoryCopyWithImpl<$Res, _$_SearchHistory>
    implements _$$_SearchHistoryCopyWith<$Res> {
  __$$_SearchHistoryCopyWithImpl(
      _$_SearchHistory _value, $Res Function(_$_SearchHistory) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? server = null,
  }) {
    return _then(_$_SearchHistory(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      server: null == server
          ? _value.server
          : server // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@HiveType(typeId: 1, adapterName: 'SearchHistoryAdapter')
class _$_SearchHistory with DiagnosticableTreeMixin implements _SearchHistory {
  const _$_SearchHistory(
      {@HiveField(0, defaultValue: '') this.query = '*',
      @HiveField(1, defaultValue: '') this.server = ''});

  @override
  @JsonKey()
  @HiveField(0, defaultValue: '')
  final String query;
  @override
  @JsonKey()
  @HiveField(1, defaultValue: '')
  final String server;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchHistory(query: $query, server: $server)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchHistory'))
      ..add(DiagnosticsProperty('query', query))
      ..add(DiagnosticsProperty('server', server));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SearchHistory &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.server, server) || other.server == server));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, server);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SearchHistoryCopyWith<_$_SearchHistory> get copyWith =>
      __$$_SearchHistoryCopyWithImpl<_$_SearchHistory>(this, _$identity);
}

abstract class _SearchHistory implements SearchHistory {
  const factory _SearchHistory(
      {@HiveField(0, defaultValue: '') final String query,
      @HiveField(1, defaultValue: '') final String server}) = _$_SearchHistory;

  @override
  @HiveField(0, defaultValue: '')
  String get query;
  @override
  @HiveField(1, defaultValue: '')
  String get server;
  @override
  @JsonKey(ignore: true)
  _$$_SearchHistoryCopyWith<_$_SearchHistory> get copyWith =>
      throw _privateConstructorUsedError;
}
