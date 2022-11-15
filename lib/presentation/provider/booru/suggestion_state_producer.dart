import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/suggestion_state.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestionStateProvider =
    StateNotifierProvider.autoDispose<SuggestionStateProducer, SuggestionState>(
        (ref) {
  final server = ref.watch(ServerSettingsProvider.active);
  final repo = ref.watch(booruRepoProvider(server));
  return SuggestionStateProducer(ref, repo);
});

class SuggestionStateProducer extends StateNotifier<SuggestionState> {
  SuggestionStateProducer(this.ref, this.repo)
      : super(const SuggestionState.data({}));
  final BooruRepo repo;
  final Ref ref;
  final Set<String> _data = {};

  Future<void> get(String query) async {
    final server = ref.read(ServerSettingsProvider.active);
    if (server == ServerData.empty) {
      _data.clear();
      state = const SuggestionState.data({});
      return;
    }

    state = SuggestionState.loading(_data);
    final res = await repo.getSuggestion(query);
    res.when(
      data: (data, src) {
        final blockedTags = ref.read(blockedTagsRepoProvider);
        _data.clear();
        _data.addAll(
          data.where((it) => !blockedTags.get().values.contains(it)),
        );
        state = SuggestionState.data(_data);
      },
      error: (res, error, stackTrace) {
        state = SuggestionState.error(
          _data,
          error: error,
          stackTrace: stackTrace,
          code: res.statusCode ?? 0,
        );
      },
    );
  }
}
