import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion_state.g.dart';

@riverpod
class SuggestionState extends _$SuggestionState {
  late BooruRepo _repo;
  late ServerData _server;

  @override
  FetchResult<ISet<String>> build() {
    _server = ref.watch(serverSettingStateProvider.select((it) => it.active));
    _repo = ref.read(booruRepoProvider(_server));
    return const FetchResult.data(ISetConst({}));
  }

  Future<void> get(String query) async {
    if (_server == ServerData.empty) {
      state = const FetchResult.data(ISetConst({}));
      return;
    }

    state = FetchResult.loading(state.data);
    try {
      final res = await _repo.getSuggestion(query);
      res.when(
        data: (data, src) {
          final blockedTags = ref.read(blockedTagsRepoProvider);
          final result = data
              .where((it) => !blockedTags.get().values.contains(it))
              .toISet();

          state = FetchResult.data(result);
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
