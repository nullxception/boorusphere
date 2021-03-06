import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../settings/active_server.dart';
import '../entity/search_history.dart';

final searchHistoryProvider = Provider((ref) => SearchHistorySource(ref));

class SearchHistorySource {
  final Ref ref;

  SearchHistorySource(this.ref);

  Box get _box => Hive.box('searchHistory');

  Map composeSuggestion({required String query}) {
    final history = mapped;
    final queries = query.split(' ');

    if (query.endsWith(' ') || query.isEmpty) {
      return history;
    }

    // Filtering history that contains last word from any state (either incomplete
    // or already contains multiple words)
    return history
      ..removeWhere((key, value) =>
          !value.query.contains(queries.last) ||
          queries.sublist(0, queries.length - 1).contains(value.query));
  }

  Map get mapped => _box.toMap();

  void clear() {
    _box.clear();
  }

  void delete(key) {
    _box.delete(key);
  }

  bool checkExists({required String value}) {
    if (_box.isEmpty) return false;

    final pageData = _box.values.firstWhere(
      (it) => it.query == value,
      orElse: () => const SearchHistory(),
    );
    return pageData.query == value;
  }

  void push(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    final activeServer = ref.read(activeServerProvider);

    if (!checkExists(value: query)) {
      _box.add(SearchHistory(
        query: query,
        server: activeServer.name,
      ));
    }
  }
}
