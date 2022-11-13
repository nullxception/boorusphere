import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
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

  static const String key = 'searchHistory';
  static Future<void> prepare() => Hive.openBox<SearchHistory>(key);
}
