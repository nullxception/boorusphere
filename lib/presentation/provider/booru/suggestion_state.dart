import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/settings/server_settings.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion_state.g.dart';

@riverpod
class SuggestionState extends _$SuggestionState {
  late BooruRepo repo;

  @override
  FetchResult<ISet<String>> build() {
    final server =
        ref.watch(serverSettingsStateProvider.select((it) => it.active));
    repo = ref.read(booruRepoProvider(server));

    return const FetchResult.data(ISetConst({}));
  }

  Future<void> get(String query) async {
    final server =
        ref.watch(serverSettingsStateProvider.select((it) => it.active));
    if (server == ServerData.empty) {
      state = const FetchResult.data(ISetConst({}));
      return;
    }

    state = FetchResult.loading(state.data);
    try {
      final res = await repo.getSuggestion(query);
      res.when(
        data: (data, src) {
          final blockedTags = ref.read(blockedTagsRepoProvider);
          final result =
              data.where((it) => !blockedTags.get().values.contains(it));

          state = FetchResult.data(state.data.addAll(result));
        },
        error: (res, error, stackTrace) {
          state = FetchResult.error(
            state.data,
            error: error,
            stackTrace: stackTrace,
            code: res.statusCode ?? 0,
          );
        },
      );
    } catch (e, s) {
      state = FetchResult.error(state.data, error: e, stackTrace: s);
    }
  }
}
