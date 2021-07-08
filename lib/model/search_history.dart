import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'search_history.freezed.dart';
part 'search_history.g.dart';

@freezed
class SearchHistory with _$SearchHistory {
  @HiveType(typeId: 1, adapterName: 'SearchHistoryAdapter')
  const factory SearchHistory({
    @HiveField(0) @Default('*') String query,
    @HiveField(1) @Default('Safebooru') String server,
  }) = _SearchHistory;
}
