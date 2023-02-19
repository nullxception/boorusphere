import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final suggestionStateProvider = StateNotifierProvider.autoDispose<
    SuggestionState,
    FetchResult<ISet<String>>>((ref) => throw UnimplementedError());

class SuggestionState extends StateNotifier<FetchResult<ISet<String>>> {
  SuggestionState(this.ref, this.serverId)
      : super(const FetchResult.data(ISetConst({})));

  final Ref ref;
  final String serverId;

  ServerData get server => ref.read(serverDataStateProvider).getById(serverId);

  Future<void> get(String query) async {
    if (server == ServerData.empty) {
      state = const FetchResult.data(ISetConst({}));
      return;
    }

    state = FetchResult.loading(state.data);
    try {
      final res =
          await ref.read(booruRepoProvider(server)).getSuggestion(query);
      res.when(
        data: (data, src) {
          final blockedTags = ref.read(blockedTagsRepoProvider);
          final result = data
              .where((it) =>
                  !blockedTags.get().values.map((e) => e.name).contains(it))
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
