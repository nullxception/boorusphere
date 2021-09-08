import 'package:fimber/fimber.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/search_history.dart';
import 'hive_boxes.dart';
import 'server_data.dart';

class SearchHistoryRepository {
  final Reader read;

  SearchHistoryRepository(this.read);

  Future<Map> composeSuggestion({String query = '*'}) async {
    final history = await mapped;
    final queries = query.trim().split(' ');
    final last = queries.last.trim();

    // Filter the query, it must be longer than 2
    if (query.endsWith(' ') || last.length < 2) {
      return history;
    }

    // Filtering history that contains last word from any state (either incomplete
    // or already contains multiple words)
    return history
      ..removeWhere((key, value) =>
          !value.query.contains(last) ||
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
    final query = value.trim();
    if (query.isEmpty) throw Exception('value must not be empty');

    final data = await read(searchHistoryBox);
    if (data.isEmpty) return false;

    final search = data.values.firstWhere(
      (it) => it.query == query,
      orElse: () => const SearchHistory(),
    );
    return search.query == query;
  }

  Future<void> push(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final history = await read(searchHistoryBox);
    final server = await read(serverDataProvider);
    try {
      if (!await checkExists(value: query)) {
        history.add(SearchHistory(
          query: query,
          server: server.active.name,
        ));
      }
    } on Exception catch (e) {
      Fimber.d('Caught an Exception', ex: e);
    }
  }
}

final searchHistoryProvider =
    Provider((ref) => SearchHistoryRepository(ref.read));
