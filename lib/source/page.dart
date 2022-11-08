import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entity/page_option.dart';
import '../entity/post.dart';
import '../entity/server_data.dart';
import '../entity/sphere_exception.dart';
import '../services/http.dart';
import '../utils/extensions/string.dart';
import 'api/parser/danboorujson_parser.dart';
import 'api/parser/e621json_parser.dart';
import 'api/parser/gelboorujson_parser.dart';
import 'api/parser/gelbooruxml_parser.dart';
import 'api/parser/konachanjson_parser.dart';
import 'api/parser/safebooruxml_parser.dart';
import 'blocked_tags.dart';
import 'search_history.dart';
import 'settings/safe_mode.dart';
import 'settings/server/active.dart';
import 'settings/server/post_limit.dart';

final pageDataProvider = Provider(PageDataSource.new);
final pageOptionProvider = StateProvider((_) => const PageOption(clear: true));
final pageStateProvider = FutureProvider((ref) {
  ref.watch(serverActiveProvider);
  ref.watch(pageOptionProvider);
  return ref.watch(pageDataProvider)._fetch();
});

class PageDataSource {
  PageDataSource(this.ref);

  final Ref ref;
  final List<Post> posts = [];
  final List<Cookie> _cookies = [];

  int _page = 0;
  int _skipCount = 0;

  String get cookies => CookieManager.getCookies(_cookies);

  List<Post> _parse(ServerData server, Response res) {
    final data = res.data;

    if (res.statusCode != 200) {
      throw SphereException(
          message: 'Cannot fetch page (HTTP ${res.statusCode})');
    } else if (!data.toString().contains(RegExp('https?'))) {
      // no url founds in the document means no image(s) available to display
      return [];
    }

    final parser = [
      DanbooruJsonParser(server),
      KonachanJsonParser(server),
      GelbooruXmlParser(server),
      GelbooruJsonParser(server),
      E621JsonParser(server),
      SafebooruXmlParser(server),
    ];

    try {
      return parser.firstWhere((it) => it.canParsePage(res)).parsePage(res);
    } on StateError {
      throw const SphereException(message: 'Cannot parse result');
    }
  }

  Future<void> _fetch() async {
    final client = ref.read(httpProvider);
    final pageOption = ref.read(pageOptionProvider);
    final serverActive = ref.read(serverActiveProvider);
    final safeMode = ref.read(safeModeProvider);
    final blockedTags = ref.read(blockedTagsProvider);
    final postLimit = ref.read(serverPostLimitProvider);
    if (serverActive == ServerData.empty) return;

    if (pageOption.query.isNotEmpty) {
      await ref.read(searchHistoryProvider.notifier).save(pageOption.query);
    }

    if (pageOption.clear) posts.clear();
    if (posts.isEmpty) _page = 0;

    final url = serverActive.searchUrlOf(
      pageOption.query,
      _page,
      safeMode,
      postLimit,
    );
    final res = await client.get(url);
    final page = _parse(serverActive, res);

    if (page.isEmpty) {
      final pageOption = ref.read(pageOptionProvider);
      final safeMode = ref.read(safeModeProvider);
      throw SphereException(
          message: [
        posts.isEmpty ? 'No result found' : 'No more result found',
        if (pageOption.query.isNotEmpty) 'for ${pageOption.query}',
        if (safeMode) 'in safe mode',
      ].join(' '));
    }

    _page++;
    final newPosts = page
        .where((it) =>
            !it.tags.any(blockedTags.values.contains) &&
            !posts.any((post) => post.id == it.id))
        .toList();

    if (newPosts.isEmpty) {
      _skipToNextPage();
      return;
    }

    final cookieJar = ref.watch(cookieProvider);
    final cookies = await cookieJar.loadForRequest(url.asUri);
    if (cookies.isNotEmpty) {
      _cookies
        ..clear()
        ..addAll(cookies);
    }
    posts.addAll(newPosts);
    _skipCount = 0;
  }

  void _skipToNextPage() {
    if (_skipCount > 3) return;
    _skipCount++;
    Future.delayed(const Duration(milliseconds: 150), _fetch);
  }

  static void loadMore(WidgetRef ref) {
    final recentState = ref.read(pageStateProvider);
    if (recentState.asData == null) return;
    ref
        .read(pageOptionProvider.notifier)
        .update((it) => it.copyWith(clear: false));
  }
}
