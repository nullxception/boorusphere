import 'dart:async';
import 'dart:io';

import 'package:boorusphere/data/entity/sphere_exception.dart';
import 'package:boorusphere/data/provider/dio.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider/blocked_tags.dart';
import 'package:boorusphere/domain/provider/booru.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/presentation/provider/search_history.dart';
import 'package:boorusphere/presentation/provider/setting/safe_mode.dart';
import 'package:boorusphere/presentation/provider/setting/server/post_limit.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageProvider = StateNotifierProvider<BooruPage, int>((ref) {
  final repo = ref.watch(booruRepoProvider);
  return BooruPage(ref, repo);
});

final pageOptionProvider = StateProvider(
  (ref) => PageOption(
    clear: true,
    limit: ref.read(serverPostLimitProvider),
    safeMode: ref.read(safeModeProvider),
  ),
);

final fetchPageProvider = FutureProvider((ref) {
  final pageOption = ref.watch(pageOptionProvider);
  final limit = ref.watch(serverPostLimitProvider);
  final safeMode = ref.watch(safeModeProvider);
  final option = pageOption.copyWith(limit: limit, safeMode: safeMode);
  final pageNotifier = ref.watch(pageProvider.notifier);
  final blockedTags = ref.read(
    blockedTagsRepoProvider.select((repo) => repo.get().values),
  );

  if (pageOption.query.isNotEmpty) {
    ref.read(searchHistoryStateProvider.notifier).save(pageOption.query);
  }

  return pageNotifier.fetch(option, blockedTags);
});

class BooruPage extends StateNotifier<int> {
  BooruPage(this.ref, this.repo) : super(0);

  final Ref ref;
  final BooruRepo repo;

  int _skipCount = 0;

  Future<void> fetch(
    PageOption option,
    Iterable<String> blockedTags,
  ) async {
    final data = ref.read(postsProvider);
    if (repo.server == ServerData.empty) return;

    if (option.clear) data.clear();
    if (data.isEmpty) state = 0;

    final page = await repo.getPage(option, state);

    if (page.data.isEmpty) {
      throw SphereException(
          message: [
        data.isEmpty ? 'No result found' : 'No more result found',
        if (option.query.isNotEmpty) 'for ${option.query}',
        if (option.safeMode) 'in safe mode',
      ].join(' '));
    }

    state++;
    final newPosts = page.data
        .where((it) =>
            !it.tags.any(blockedTags.contains) &&
            !data.any((post) => post.id == it.id))
        .toList();

    if (newPosts.isEmpty) {
      if (_skipCount > 3) return;
      _skipCount++;
      return Future.delayed(
        const Duration(milliseconds: 150),
        () => fetch(option, blockedTags),
      );
    }

    final cookies =
        await ref.read(cookieJarProvider).loadForRequest(page.src.asUri);

    if (cookies.isNotEmpty) {
      ref.read(cookieProvider)
        ..clear()
        ..addAll(cookies);
    }

    data.addAll(newPosts);
    _skipCount = 0;
  }

  static final postsProvider = Provider((ref) => <Post>[]);
  static final cookieProvider = Provider((ref) => <Cookie>[]);
}

class PageUtil {
  static void loadMore(WidgetRef ref) {
    final recentPage = ref.read(fetchPageProvider);
    if (recentPage.asData == null) return;
    ref
        .read(pageOptionProvider.notifier)
        .update((it) => it.copyWith(clear: false));
  }
}
