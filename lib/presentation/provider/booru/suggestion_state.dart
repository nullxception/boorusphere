import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final suggestionStateProvider = StateNotifierProvider.autoDispose<
    SuggestionState, FetchResult<Iterable<String>>>((ref) {
  throw UnimplementedError();
});

class SuggestionState extends StateNotifier<FetchResult<Iterable<String>>> {
  SuggestionState(this.ref, this.serverId) : super(const FetchResult.idle([]));

  final Ref ref;
  final String serverId;

  ServerData get server => ref.read(serverDataStateProvider).getById(serverId);

  String? _lastQuery;

  Future<void> get(String query) async {
    if (_lastQuery == query) return;
    if (server == ServerData.empty) {
      state = const FetchResult.data([]);
      return;
    }

    state = FetchResult.loading(state.data);
    _lastQuery = query;
    try {
      final queries = query.toWordList();
      final word = queries.isEmpty || query.endsWith(' ') ? '' : queries.last;
      final res = await ref.read(booruRepoProvider(server)).getSuggestion(word);
      final blockedTags = ref.read(blockedTagsRepoProvider);
      final result = res
          .where(
              (it) => !blockedTags.get().values.map((e) => e.name).contains(it))
          .toSet();
      if (query != _lastQuery) return;

      if (result.isEmpty && word.isNotEmpty) {
        state = FetchResult.error(state.data, error: BooruError.empty);
        return;
      }

      state = FetchResult.data(result);
    } catch (err, stack) {
      if (query != _lastQuery) return;
      state = FetchResult.error(state.data, error: err, stackTrace: stack);
    }
  }
}
