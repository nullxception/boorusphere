import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/settings/server/active.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion_state.g.dart';

@riverpod
class SuggestionState extends _$SuggestionState {
  final Set<String> _data = {};
  late BooruRepo repo;

  @override
  FetchState<Set<String>> build() {
    final server = ref.watch(serverActiveSettingStateProvider);
    repo = ref.read(booruRepoProvider(server));
    return const FetchState.data({});
  }

  Future<void> get(String query) async {
    final server = ref.read(serverActiveSettingStateProvider);
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
