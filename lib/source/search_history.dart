import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../settings/active_server.dart';
import '../entity/search_history.dart';

final searchHistoryProvider =
    StateNotifierProvider<SearchHistorySource, Map<int, SearchHistory>>(
        (ref) => SearchHistorySource(ref));

class SearchHistorySource extends StateNotifier<Map<int, SearchHistory>> {
  SearchHistorySource(this.ref) : super({});

  final Ref ref;

  Box get _box => Hive.box('searchHistory');

  Map<int, SearchHistory> get all =>
      _box.toMap().map((key, value) => MapEntry(key, value));

  void rebuild(String query) {
    final queries = query.split(' ');

    if (query.endsWith(' ') || query.isEmpty) {
      state = all;
      return;
    }

    // Filtering history that contains last word from any state (either incomplete
    // or already contains multiple words)
    final filtered = all;

    filtered.removeWhere((key, value) =>
        !value.query.contains(queries.last) ||
        queries.sublist(0, queries.length - 1).contains(value.query));
    state = filtered;
  }

  void clear() {
    _box.clear();
    state = {};
  }

  void delete(key) {
    final newState = all;
    newState.remove(key);
    _box.delete(key);
    state = newState;
  }

  bool checkExists({required String value}) {
    if (_box.isEmpty) return false;
    final values = _box.values.cast<SearchHistory>();
    final pageData = values.firstWhere(
      (it) => it.query == value,
      orElse: () => const SearchHistory(),
    );
    return pageData.query == value;
  }

  void save(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    final activeServer = ref.read(activeServerProvider);

    if (!checkExists(value: query)) {
      final newEntry = SearchHistory(query: query, server: activeServer.name);
      _box.add(newEntry);
    }
  }
}
