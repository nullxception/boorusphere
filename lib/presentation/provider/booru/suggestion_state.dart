import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestionProvider = StateNotifierProvider.autoDispose<
    SuggestionStateNotifier, FetchState<Set<String>>>((ref) {
  final server = ref.watch(ServerSettingsProvider.active);
  final repo = ref.watch(booruRepoProvider(server));
  return SuggestionStateNotifier(ref, repo);
});

class SuggestionStateNotifier extends StateNotifier<FetchState<Set<String>>> {
  SuggestionStateNotifier(this.ref, this.repo)
      : super(const FetchState.data({}));
  final BooruRepo repo;
  final Ref ref;
  final Set<String> _data = {};

  Future<void> get(String query) async {
    final server = ref.read(ServerSettingsProvider.active);
    if (server == ServerData.empty) {
      _data.clear();
      state = const FetchState.data({});
      return;
    }

    state = FetchState.loading(_data);
    try {
      final res = await repo.getSuggestion(query);
      res.when(
        data: (data, src) {
          final blockedTags = ref.read(blockedTagsRepoProvider);
          _data.clear();
          _data.addAll(
            data.where((it) => !blockedTags.get().values.contains(it)),
          );
          state = FetchState.data(_data);
        },
        error: (res, error, stackTrace) {
          state = FetchState.error(
            _data,
            error: error,
            stackTrace: stackTrace,
            code: res.statusCode ?? 0,
          );
        },
      );
    } catch (e, s) {
      state = FetchState.error(_data, error: e, stackTrace: s);
    }
  }
}
