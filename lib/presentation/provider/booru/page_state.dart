import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  PageState({this.serverId = ''});

  final String serverId;
  final _posts = <Post>[];
  int _skipCount = 0;
  int _page = 0;

  @override
  FetchResult<PageData> build() {
    _skipCount = 0;
    _page = 0;
    _posts.clear();
    return const FetchResult.idle(PageData());
  }

  ServerData get _server {
    return ref.read(serverDataStateProvider).getById(serverId);
  }

  Iterable<String> get blockedTags {
    return ref
        .read(blockedTagsStateProvider)
        .values
        .where((it) => it.serverId.isEmpty || it.serverId == _server.id)
        .map((it) => it.name);
  }

  Future<void> update(PageOption Function(PageOption) updater) async {
    final newOption = updater(state.data.option);
    state = state.copyWith(data: state.data.copyWith(option: newOption));
    await load();
  }

  Future<void> load() async {
    if (_server == ServerData.empty) return;
    final settings = ref.read(serverSettingStateProvider);
    final newOption = state.data.option.copyWith(
      limit: settings.postLimit,
      searchRating: settings.searchRating,
    );

    if (newOption.query.isNotEmpty) {
      await ref
          .read(searchHistoryStateProvider.notifier)
          .save(newOption.query, _server);
    }

    try {
      state = state.copyWith(data: state.data.copyWith(option: newOption));

      await _fetch();
    } catch (error, stackTrace) {
      state = FetchResult.error(
        state.data,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loadMore() async {
    if (state is! DataFetchResult) return;

    await update((it) => it.copyWith(clear: false));
  }

  Future<void> _fetch() async {
    final repo = ref.read(booruRepoProvider(_server));
    if (state.data.option.clear) {
      _page = 0;
      _posts.clear();
    }
    state = FetchResult.loading(state.data.copyWith(posts: _posts));

    if (state.data.option.query.toWordList().any(blockedTags.contains)) {
      state = FetchResult.error(state.data, error: BooruError.tagsBlocked);
      return;
    }

    try {
      final res = await repo.getPage(state.data.option, _page);
      if (res.isEmpty) {
        state = FetchResult.error(state.data, error: BooruError.empty);
        return;
      }

      _page++;

      final posts = res.where((it) => !_posts.any((post) => post.id == it.id));
      final displayedPosts =
          posts.where((it) => !it.allTags.any(blockedTags.contains));
      if (displayedPosts.isEmpty) {
        if (_skipCount > 3) return;
        _skipCount++;
        return Future.delayed(const Duration(milliseconds: 150), _fetch);
      }
      _skipCount = 0;
      if (posts.isEmpty) {
        state = FetchResult.error(state.data, error: BooruError.empty);
        return;
      }

      _posts.addAll(posts);
      state = FetchResult.data(state.data.copyWith(posts: _posts));
    } catch (err, stack) {
      state = FetchResult.error(state.data, error: err, stackTrace: stack);
    }
  }

  void reset() {
    _page = 0;
    _skipCount = 0;
    update((it) => it.copyWith(clear: true));
  }
}
