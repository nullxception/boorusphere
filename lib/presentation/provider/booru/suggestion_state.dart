import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
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
      final res =
          await ref.read(booruRepoProvider(server)).getSuggestion(query);
      res.when(
        data: (data, src) {
          final blockedTags = ref.read(blockedTagsRepoProvider);
          final result = data
              .where((it) =>
                  !blockedTags.get().values.map((e) => e.name).contains(it))
              .toSet();
          if (query != _lastQuery) return;
          state = FetchResult.data(result);
        },
        error: (res, error, stackTrace) {
          if (query != _lastQuery) return;
          state = FetchResult.error(
            state.data,
            error: error,
            stackTrace: stackTrace,
            code: res.statusCode ?? 0,
          );
        },
      );
    } catch (e, s) {
      if (query != _lastQuery) return;
      state = FetchResult.error(state.data, error: e, stackTrace: s);
    }
  }
}
