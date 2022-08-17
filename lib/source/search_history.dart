import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../entity/search_history.dart';
import '../utils/extensions/string.dart';
import 'settings/server/active.dart';

final searchHistoryProvider =
    StateNotifierProvider<SearchHistorySource, Map<int, SearchHistory>>((ref) {
  final storage = SearchHistorySource._storage;
  return SearchHistorySource(ref, Map.from(storage.toMap()));
});

final searchHistoryFinder =
    Provider.family<Map<int, SearchHistory>, String>((ref, query) {
  final history = ref.watch(searchHistoryProvider);
  if (query.endsWith(' ') || query.isEmpty) {
    return history;
  }

  final queries = query.toWordList();
  // Filtering history that contains last word from any state (either incomplete
  // or already contains multiple words)
  final filtered = Map<int, SearchHistory>.from(history);
  filtered.removeWhere((key, value) =>
      !value.query.contains(queries.last) ||
      queries.take(queries.length).contains(value.query));

  return filtered;
});

class SearchHistorySource extends StateNotifier<Map<int, SearchHistory>> {
  SearchHistorySource(this.ref, super.state);

  final Ref ref;

  void _refresh() {
    state = Map.from(_storage.toMap());
  }

  Future<void> clear() async {
    await _storage.clear();
    _refresh();
  }

  Future<void> delete(key) async {
    await _storage.delete(key);
    _refresh();
  }

  bool checkExists(String value) {
    return state.values.map((e) => e.query).contains(value);
  }

  Future<void> save(String value) async {
    final query = value.trim();
    if (query.isEmpty || checkExists(query)) return;

    final serverActive = ref.read(serverActiveProvider);
    await _storage.add(SearchHistory(query: query, server: serverActive.name));
    _refresh();
  }

  static Box get _storage => Hive.box('searchHistory');
}
