import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchHistoryStateProvider =
    StateNotifierProvider<SearchHistoryState, Map<int, SearchHistory>>((ref) {
  final repo = ref.watch(searchHistoryRepoProvider);
  return SearchHistoryState(ref, repo);
});

final filteredHistoryProvider =
    Provider.family<Map<int, SearchHistory>, String>((ref, query) {
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
});

class SearchHistoryState extends StateNotifier<Map<int, SearchHistory>> {
  SearchHistoryState(this.ref, this.repo) : super({}) {
    state = repo.all;
  }

  final Ref ref;
  final SearchHistoryRepo repo;

  Future<void> save(String value) async {
    final serverActive = ref.read(ServerSettingsProvider.active);
    await repo.save(value.trim(), serverActive.id);
    state = repo.all;
  }

  Future<void> delete(key) async {
    await repo.delete(key);
    state = repo.all;
  }

  Future<void> clear() async {
    await repo.clear();
    state = repo.all;
  }
}
