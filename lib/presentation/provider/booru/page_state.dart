import 'dart:async';

import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/search_history.dart';
import 'package:boorusphere/presentation/provider/settings/server_settings.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  late BooruRepo repo;
  late int _skipCount;
  late int _page;

  @override
  FetchState<PageData> build() {
    final server =
        ref.watch(serverSettingsStateProvider.select((it) => it.active));
    repo = ref.read(booruRepoProvider(server));
    _skipCount = 0;
    _page = 0;

    // throw initial load side-effect somewhere else lol
    Future(load);
    return const FetchState.data(PageData(option: PageOption(clear: true)));
  }

  Future<void> update(PageOption Function(PageOption) updater) async {
    state = state.copyWith(
      data: state.data.copyWith(
        option: updater(state.data.option),
      ),
    );
    await load();
  }

  Future<void> load() async {
    if (repo.server == ServerData.empty) return;
    final settings = ref.read(serverSettingsStateProvider);
    state = state.copyWith(
      data: state.data.copyWith(
        option: state.data.option.copyWith(
          limit: settings.postLimit,
          safeMode: settings.safeMode,
        ),
      ),
    );

    if (state.data.option.query.isNotEmpty) {
      await ref
          .read(searchHistoryStateProvider.notifier)
          .save(state.data.option.query);
    }

    try {
      await _fetch();
    } catch (error, stackTrace) {
      state = FetchState.error(
        state.data,
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

    if (state.data.option.clear) {
      state = FetchState.loading(state.data.copyWith(posts: []));
    } else {
      state = FetchState.loading(state.data);
    }

    if (state.data.posts.isEmpty) _page = 0;

    final lastHashCode = repo.hashCode;
    final pageResult = await repo.getPage(state.data.option, _page);
    return pageResult.when<void>(
      data: (page, src) async {
        if (lastHashCode != repo.hashCode) return;
        if (page.isEmpty) {
          state = FetchState.error(state.data, error: BooruError.empty);
          return;
        }

        _page++;
        final newPosts = page
            .where((it) =>
                !it.tags.any(blockedTags.contains) &&
                !state.data.posts.any((post) => post.id == it.id))
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

        state = FetchState.data(
          state.data.copyWith(
            posts: [...state.data.posts, ...newPosts],
            cookies: [...fromJar],
          ),
        );
      },
      error: (res, error, stackTrace) {
        state = FetchState.error(
          state.data,
          error: error,
          stackTrace: stackTrace,
          code: res.statusCode ?? 0,
        );
      },
    );
  }
}
