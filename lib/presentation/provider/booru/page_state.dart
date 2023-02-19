import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pageStateProvider =
    StateNotifierProvider.autoDispose<PageState, FetchResult<PageData>>(
        (ref) => throw UnimplementedError());

class PageState extends StateNotifier<FetchResult<PageData>> {
  PageState(this.ref, this.serverId)
      : super(const FetchResult.loading(
            PageData(posts: [], option: PageOption(query: '', clear: true))));

  final Ref ref;
  final String serverId;

  int _skipCount = 0;
  int _page = 0;
  ServerData get server => ref.read(serverDataStateProvider).getById(serverId);

  Iterable<String> get blockedTags {
    return ref
        .read(blockedTagsStateProvider)
        .values
        .where((it) => it.serverId.isEmpty || it.serverId == server.id)
        .map((it) => it.name);
  }

  Future<void> update(PageOption Function(PageOption) updater) async {
    final newOption = updater(state.data.option);
    state = state.copyWith(data: state.data.copyWith(option: newOption));
    await load();
  }

  Future<void> load() async {
    if (server == ServerData.empty) return;
    final settings = ref.read(serverSettingStateProvider);
    final newOption = state.data.option.copyWith(
      limit: settings.postLimit,
      searchRating: settings.searchRating,
    );

    if (newOption.query.isNotEmpty) {
      await ref
          .read(searchHistoryStateProvider.notifier)
          .save(newOption.query, server);
    }

    try {
      if (hasListeners) {
        state = state.copyWith(data: state.data.copyWith(option: newOption));
      }

      await _fetch();
    } catch (error, stackTrace) {
      if (hasListeners) {
        state = FetchResult.error(
          state.data,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state is! DataFetchResult) return;

    await update((it) => it.copyWith(clear: false));
  }

  Future<void> _fetch() async {
    final repo = ref.read(booruRepoProvider(server));
    if (state.data.option.clear) {
      _page = 1;
    }
    state = FetchResult.loading(state.data);

    if (state.data.option.query.toWordList().any(blockedTags.contains)) {
      state = FetchResult.error(state.data, error: BooruError.tagsBlocked);
      return;
    }

    final lastHashCode = repo.hashCode;
    final pageResult = await repo.getPage(state.data.option, _page);
    return pageResult.when<void>(
      data: (posts, src) async {
        if (lastHashCode != repo.hashCode) return;
        if (posts.isEmpty) {
          state = FetchResult.error(state.data, error: BooruError.empty);
          return;
        }

        _page++;

        final displayedPosts =
            posts.where((it) => !it.allTags.any(blockedTags.contains));
        if (displayedPosts.isEmpty) {
          if (_skipCount > 3) return;
          _skipCount++;
          return Future.delayed(const Duration(milliseconds: 150), _fetch);
        }
        _skipCount = 0;

        if (lastHashCode != repo.hashCode) return;
        state = FetchResult.data(state.data.copyWith(posts: posts));
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
  }

  void reset() {
    _page = 0;
    _skipCount = 0;
    update((it) => it.copyWith(clear: true));
  }
}
