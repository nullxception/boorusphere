import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion_state.g.dart';

@riverpod
class SuggestionState extends _$SuggestionState {
  late BooruRepo repo;

  @override
  FetchState<Set<String>> build() {
    final server =
        ref.watch(serverSettingsStateProvider.select((it) => it.active));
    repo = ref.read(booruRepoProvider(server));

    return const FetchState.data({});
  }

  Future<void> get(String query) async {
    final server =
        ref.watch(serverSettingsStateProvider.select((it) => it.active));
    if (server == ServerData.empty) {
      state = const FetchState.data({});
      return;
    }

    state = FetchState.loading(state.data);
    try {
      final res = await repo.getSuggestion(query);
      res.when(
        data: (data, src) {
          final blockedTags = ref.read(blockedTagsRepoProvider);
          final result =
              data.where((it) => !blockedTags.get().values.contains(it));

          state = FetchState.data({...state.data, ...result});
        },
        error: (res, error, stackTrace) {
          state = FetchState.error(
            state.data,
            error: error,
            stackTrace: stackTrace,
            code: res.statusCode ?? 0,
          );
        },
      );
    } catch (e, s) {
      state = FetchState.error(state.data, error: e, stackTrace: s);
    }
  }
}
