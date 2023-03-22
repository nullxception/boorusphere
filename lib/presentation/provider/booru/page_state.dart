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
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  PageState({this.session = const SearchSession()});

  final SearchSession session;
  final _posts = <Post>[];
  int _page = 0;

  @override
  FetchResult<PageData> build() {
    _page = 0;
    _posts.clear();
    return const FetchResult.idle(PageData());
  }

  ServerData get _server {
    return ref.read(serverDataStateProvider).getById(session.serverId);
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
    final query = state.data.option.query;
    if (query.toWordList().any(blockedTags.contains)) {
      state = FetchResult.error(state.data, error: BooruError.tagsBlocked);
      return;
    }

    if (query.isNotEmpty) {
      await ref.read(searchHistoryStateProvider.notifier).save(query, _server);
    }

    final settings = ref.read(serverSettingStateProvider);
    final option = state.data.option.copyWith(
      limit: settings.postLimit,
      searchRating: settings.searchRating,
    );

    if (option.clear) {
      _page = 0;
      _posts.clear();
    }

    state = FetchResult.loading(
      state.data.copyWith(posts: _posts, option: option),
    );

    try {
      final repo = ref.read(booruRepoProvider(_server));
      var skipCount = 0;
      while (skipCount <= 3) {
        final res = await repo.getPage(option, _page);
        if (res.isEmpty) {
          state = FetchResult.error(state.data, error: BooruError.empty);
          return;
        }
        _page++;

        final posts =
            res.where((it) => !_posts.any((post) => post.id == it.id));
        final displayedPosts =
            posts.where((it) => !it.allTags.any(blockedTags.contains));
        if (displayedPosts.isNotEmpty) {
          _posts.addAll(posts);
          state = FetchResult.data(state.data.copyWith(posts: _posts));
          break;
        }

        skipCount++;
      }
    } catch (err, stack) {
      state = FetchResult.error(state.data, error: err, stackTrace: stack);
    }
  }

  Future<void> loadMore() async {
    if (state is! DataFetchResult) return;

    await update((it) => it.copyWith(clear: false));
  }
}
