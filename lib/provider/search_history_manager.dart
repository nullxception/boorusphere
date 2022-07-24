import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/search_history.dart';
import 'hive_boxes.dart';
import 'settings/active_server.dart';

final searchHistoryProvider = Provider((ref) => SearchHistoryManager(ref.read));

class SearchHistoryManager {
  final Reader read;

  SearchHistoryManager(this.read);

  Future<Map> composeSuggestion({required String query}) async {
    final history = await mapped;
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

  Future<Map> get mapped async {
    final history = await read(searchHistoryBox);
    return history.toMap();
  }

  Future<void> clear() async {
    final history = await read(searchHistoryBox);
    history.clear();
  }

  Future<void> delete(key) async {
    final history = await read(searchHistoryBox);
    history.delete(key);
  }

  Future<bool> checkExists({required String value}) async {
    final data = await read(searchHistoryBox);
    if (data.isEmpty) return false;

    final pageManager = data.values.firstWhere(
      (it) => it.query == value,
      orElse: () => const SearchHistory(),
    );
    return pageManager.query == value;
  }

  Future<void> push(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final history = await read(searchHistoryBox);
    final activeServer = read(activeServerProvider);

    if (!await checkExists(value: query)) {
      history.add(SearchHistory(
        query: query,
        server: activeServer.name,
      ));
    }
  }
}
