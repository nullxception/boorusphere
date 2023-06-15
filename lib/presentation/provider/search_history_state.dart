import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_state.g.dart';

@riverpod
Map<int, SearchHistory> filterHistory(FilterHistoryRef ref, String query) {
  final history = ref.watch(searchHistoryStateProvider);
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
}

@riverpod
class SearchHistoryState extends _$SearchHistoryState {
  @override
  Map<int, SearchHistory> build() {
    final repo = ref.read(searchHistoryRepoProvider);
    return repo.all;
  }

  Future<void> save(String value, Server server) async {
    final repo = ref.read(searchHistoryRepoProvider);
    await repo.save(value.trim(), server.id);
    state = repo.all;
  }

  Future<void> delete(key) async {
    final repo = ref.read(searchHistoryRepoProvider);
    await repo.delete(key);
    state = repo.all;
  }

  Future<void> clear() async {
    final repo = ref.read(searchHistoryRepoProvider);
    await repo.clear();
    state = repo.all;
  }
}
