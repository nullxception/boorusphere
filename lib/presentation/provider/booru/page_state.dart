import 'dart:async';
import 'dart:io';

import 'package:boorusphere/data/provider.dart';
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
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  late BooruRepo _repo;
  late ServerData _server;
  late int _skipCount;
  late int _page;
  late Map<int, String> _blockedTags;

  // Posts and Cookies holder
  // Mutable collections is used here since we'll use it on multiple
  // screens which require us to share the exact List object for
  // several reason like incoming addition from loadMore()
  // or item removal from favorites screen
  final _posts = <Post>[];
  final _cookies = <Cookie>[];

  String lastQuery = '';

  @override
  FetchResult<PageData> build() {
    _server = ref.watch(serverSettingStateProvider.select((it) => it.active));
    _blockedTags = ref.watch(blockedTagsStateProvider);
    _repo = ref.read(booruRepoProvider(_server));
    _skipCount = 0;
    _page = 0;
    _posts.clear();
    _cookies.clear();
    Future(load);
    return FetchResult.data(PageData(
      posts: _posts,
      cookies: _cookies,
      option: PageOption(query: lastQuery, clear: true),
    ));
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
    if (lastQuery.toWordList().any(_blockedTags.values.contains)) {
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
        final newPosts = page.where((it) =>
            !it.tags.any(_blockedTags.values.contains) &&
            !_posts.any((post) => post.id == it.id));

        if (newPosts.isEmpty) {
          if (_skipCount > 3) return;
          _skipCount++;
          return Future.delayed(const Duration(milliseconds: 150), _fetch);
        }
        _skipCount = 0;

        final fromJar =
            await ref.read(cookieJarProvider).loadForRequest(src.toUri());
        if (lastHashCode != _repo.hashCode) return;

        _posts.addAll(newPosts);
        _cookies
          ..clear()
          ..addAll(fromJar);

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
