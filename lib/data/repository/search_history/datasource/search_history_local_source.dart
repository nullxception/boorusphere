import 'dart:convert';

import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/presentation/provider/data_backup.dart';
import 'package:hive/hive.dart';

class SearchHistoryLocalSource {
  SearchHistoryLocalSource(this.box);
  final Box<SearchHistory> box;

  Map<int, SearchHistory> get() => Map.from(box.toMap());

  bool isExists(String value) {
    return box.values.map((e) => e.query).contains(value);
  }

  Future<void> add(String value, String serverId) async {
    final query = value.trim();
    if (query.isEmpty || isExists(query)) return;

    await box.add(SearchHistory(query: query, server: serverId));
  }

  Future<void> delete(key) => box.delete(key);

  Future<void> clear() => box.clear();

  Future<void> import(String src) async {
    final List maps = jsonDecode(src);
    if (maps.isEmpty) return;
    await box.deleteAll(box.keys);
    for (final map in maps) {
      if (map is Map) {
        final history = SearchHistory.fromJson(Map.from(map));
        await box.add(history);
      }
    }
  }

  Future<BackupItem> export() async {
    return BackupItem(key, box.values.map((e) => e.toJson()).toList());
  }

  static const String key = 'searchHistory';
  static Future<void> prepare() => Hive.openBox<SearchHistory>(key);
}
