import 'dart:async';
import 'dart:io';

import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/search_history.dart';
import 'package:boorusphere/presentation/provider/settings/server/active.dart';
import 'package:boorusphere/presentation/provider/settings/server/post_limit.dart';
import 'package:boorusphere/presentation/provider/settings/server/safe_mode.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  late BooruRepo repo;

  int _skipCount = 0;
  int _page = 0;
  PageOption _option = const PageOption(clear: true);

  List<Post> data = [];
  List<Cookie> cookies = [];

  PageOption get option => _option;

  PageData get currentData =>
      PageData(option: option, posts: data, cookies: cookies);

  @override
  FetchState<PageData> build() {
    final server = ref.watch(serverActiveSettingStateProvider);
    repo = ref.read(booruRepoProvider(server));
    // throw initial load side-effect somewhere else lol
    Future(load);
    return const FetchState.data(PageData());
  }

  Future<void> update(PageOption Function(PageOption) updater) async {
    _option = updater(option);
    await load();
  }

  Future<void> load() async {
    if (repo.server == ServerData.empty) return;
    final limit = ref.read(postLimitSettingStateProvider);
    final safeMode = ref.read(safeModeSettingStateProvider);
    _option = option.copyWith(limit: limit, safeMode: safeMode);

    if (option.query.isNotEmpty) {
      await ref.read(searchHistoryStateProvider.notifier).save(option.query);
    }

    try {
      await _fetch();
    } catch (error, stackTrace) {
      state = FetchState.error(
        currentData,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void loadMore() {
    if (state is! DataFetchState) return;

    update((it) => it.copyWith(clear: false));
  }

  Future<void> _fetch() async {
    final blockedTags = ref.read(
      blockedTagsRepoProvider.select((repo) => repo.get().values),
    );

    if (option.clear) data.clear();
    if (data.isEmpty) _page = 0;
    state = FetchState.loading(currentData);

    final lastHashCode = repo.hashCode;
    final pageResult = await repo.getPage(option, _page);
    return pageResult.when<void>(
      data: (page, src) async {
        if (lastHashCode != repo.hashCode) return;
        if (page.isEmpty) {
          state = FetchState.error(currentData, error: BooruError.empty);
          return;
        }

        _page++;
        final newPosts = page
            .where((it) =>
                !it.tags.any(blockedTags.contains) &&
                !data.any((post) => post.id == it.id))
            .toList();

        if (newPosts.isEmpty) {
          if (_skipCount > 3) return;
          _skipCount++;
          return Future.delayed(const Duration(milliseconds: 150), _fetch);
        }
        _skipCount = 0;

        final fromJar =
            await ref.read(cookieJarProvider).loadForRequest(src.asUri);
        if (lastHashCode != repo.hashCode) return;

        if (fromJar.isNotEmpty) {
          cookies
            ..clear()
            ..addAll(fromJar);
        }

        data.addAll(newPosts);
        state = FetchState.data(currentData);
      },
      error: (res, error, stackTrace) {
        state = FetchState.error(
          currentData,
          error: error,
          stackTrace: stackTrace,
          code: res.statusCode ?? 0,
        );
      },
    );
  }
}
