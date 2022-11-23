import 'dart:async';

import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_result.dart';
import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_state.g.dart';

@riverpod
class PageState extends _$PageState {
  late BooruRepo _repo;
  late ServerData _server;
  late int _skipCount;
  late int _page;
  late Map<int, String> _blockedTags;

  String lastQuery = '';

  @override
  FetchResult<PageData> build() {
    _server = ref.watch(serverSettingStateProvider.select((it) => it.active));
    _blockedTags = ref.watch(blockedTagsStateProvider);
    _repo = ref.read(booruRepoProvider(_server));
    _skipCount = 0;
    _page = 0;
    // throw initial load side-effect somewhere else
    Future(load);
    return FetchResult.data(PageData(
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
      state = FetchResult.loading(state.data.copyWith(
        posts: const IListConst([]),
      ));
    } else {
      state = FetchResult.loading(state.data);
    }

    if (state.data.posts.isEmpty) _page = 0;
    lastQuery = state.data.option.query;

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
        final newPosts = page
            .where((it) =>
                !it.tags.any(_blockedTags.values.contains) &&
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
        if (lastHashCode != _repo.hashCode) return;

        state.data.posts.addAll(newPosts);
        state = FetchResult.data(
          state.data.copyWith(
            posts: state.data.posts.addAll(newPosts),
            cookies: fromJar.lock,
          ),
        );
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
