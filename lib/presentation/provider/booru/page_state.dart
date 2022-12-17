import 'dart:async';

import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  late BooruRepo _repo;
  late ServerData _server;
  late int _skipCount;
  late int _page;

  // Posts holder
  // Mutable collections is used here since we'll use it on multiple
  // screens which require us to share the exact List object for
  // several reason like incoming addition from loadMore()
  // or item removal from favorites screen
  final _posts = <Post>[];

  String lastQuery = '';

  @override
  FetchResult<PageData> build() {
    _server = ref.watch(serverSettingStateProvider.select((it) => it.active));
    _repo = ref.read(booruRepoProvider(_server));
    _skipCount = 0;
    _page = 0;
    _posts.clear();
    Future(load);
    return FetchResult.data(PageData(
      posts: _posts,
      option: PageOption(query: lastQuery, clear: true),
    ));
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
      safeMode: settings.safeMode,
    );

    if (newOption.query.isNotEmpty) {
      await ref.read(searchHistoryStateProvider.notifier).save(newOption.query);
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

  void loadMore() {
    if (state is! DataFetchResult) return;

    update((it) => it.copyWith(clear: false));
  }

  Future<void> _fetch() async {
    if (state.data.option.clear) {
      _posts.clear();
    }
    state = FetchResult.loading(state.data);

    if (_posts.isEmpty) _page = 0;
    lastQuery = state.data.option.query;
    if (lastQuery.toWordList().any(blockedTags.contains)) {
      state = FetchResult.error(state.data, error: BooruError.tagsBlocked);
      return;
    }

    final lastHashCode = _repo.hashCode;
    final pageResult = await _repo.getPage(state.data.option, _page);
    return pageResult.when<void>(
      data: (page, src) async {
        if (lastHashCode != _repo.hashCode) return;
        if (page.isEmpty) {
          state = FetchResult.error(state.data, error: BooruError.empty);
          return;
        }

        _page++;
        final newPosts =
            page.where((it) => !_posts.any((post) => post.id == it.id));

        final displayedPosts =
            newPosts.where((it) => !it.allTags.any(blockedTags.contains));
        if (displayedPosts.isEmpty) {
          if (_skipCount > 3) return;
          _skipCount++;
          return Future.delayed(const Duration(milliseconds: 150), _fetch);
        }
        _skipCount = 0;

        if (lastHashCode != _repo.hashCode) return;

        _posts.addAll(newPosts);
        state = FetchResult.data(state.data);
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
}
