import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/active_server.dart';
import '../../settings/safe_mode.dart';
import '../../settings/server/post_limit.dart';
import '../../utils/retry_future.dart';
import '../../utils/server/response_parser.dart';
import '../entity/page_option.dart';
import '../entity/post.dart';
import '../entity/server_data.dart';
import '../entity/sphere_exception.dart';
import '../services/http.dart';
import 'blocked_tags.dart';
import 'search_history.dart';
import 'server.dart';

final pageDataProvider = Provider(PageDataSource.new);
final pageOptionProvider = StateProvider((_) => const PageOption());
final pageStateProvider = FutureProvider((ref) {
  ref.watch(activeServerProvider);
  ref.watch(pageOptionProvider);
  return ref.read(pageDataProvider)._fetch();
});

class PageDataSource {
  PageDataSource(this.ref);

  final Ref ref;
  final List<Post> posts = [];

  int _page = 0;

  String _buildErrorMessage(String message) {
    final pageOption = ref.read(pageOptionProvider);
    final safeMode = ref.read(safeModeProvider);
    final words = <String>[];

    words.add(posts.isNotEmpty
        ? message.replaceFirst('No result found', 'No more result found')
        : message);
    if (pageOption.query.isNotEmpty) words.add('for ${pageOption.query}');
    if (safeMode) words.add('in safe mode');
    return words.join(' ');
  }

  Future<void> _fetch() async {
    final client = ref.read(httpProvider);
    final pageOption = ref.read(pageOptionProvider);
    final activeServer = ref.read(activeServerProvider);
    final safeMode = ref.read(safeModeProvider);
    final blockedTags = ref.read(blockedTagsProvider);
    final postLimit = ref.read(serverPostLimitProvider);
    if (activeServer == ServerData.empty) return;

    if (pageOption.query.isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).save(pageOption.query);
    }

    if (pageOption.clear) posts.clear();
    if (posts.isEmpty) _page = 0;

    try {
      final url = activeServer.searchUrlOf(
        pageOption.query,
        _page,
        safeMode,
        postLimit,
      );
      final res = await retryFuture(
        () => client.get(Uri.parse(url)).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final data = ServerResponseParser.parsePage(activeServer, res);
      posts.addAll(data.where((it) =>
          !it.tags.any(blockedTags.listedEntries.contains) &&
          !posts.any((post) => post.id == it.id)));

      _page++;
    } catch (exception) {
      if (exception is SphereException) {
        final message = _buildErrorMessage(exception.message);
        throw SphereException(message: message);
      } else {
        rethrow;
      }
    }
  }

  void loadMore() {
    final pageState = ref.read(pageStateProvider);
    if (pageState.asData != null) {
      ref
          .read(pageOptionProvider.notifier)
          .update((state) => state.copyWith(clear: false));
    }
  }

  Future<void> initialize() async {
    final serverData = ref.read(serverDataProvider.notifier);

    await serverData.populateData();
    ref.read(activeServerProvider.notifier).restore(serverData);

    posts.clear();
  }
}
