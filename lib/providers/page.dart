import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/post.dart';
import '../data/sphere_exception.dart';
import '../utils/retry_future.dart';
import '../utils/server/response_parser.dart';
import 'blocked_tags.dart';
import 'search_history.dart';
import 'server_data.dart';
import 'settings/active_server.dart';
import 'settings/safe_mode.dart';
import 'settings/server/post_limit.dart';

final pageLoadingProvider = StateProvider((_) => false);
final pageErrorProvider = StateProvider((_) => []);
final pageManagerProvider = Provider((ref) => PageManager(ref));
final pageQueryProvider = StateProvider((_) => '');

class PageManager {
  PageManager(this.ref);

  final Ref ref;
  final List<Post> posts = [];

  int _page = 0;

  String _buildErrorMessage(String message) {
    final pageQuery = ref.read(pageQueryProvider);
    final safeMode = ref.read(safeModeProvider);
    final words = <String>[];

    words.add(posts.isNotEmpty
        ? message.replaceFirst('No result found', 'No more result found')
        : message);
    if (pageQuery.isNotEmpty) words.add('for $pageQuery');
    if (safeMode) words.add('in safe mode');
    return words.join(' ');
  }

  Future<void> fetch({String? query, bool clear = false}) async {
    final pageLoading = ref.read(pageLoadingProvider.state);
    final pageQuery = ref.read(pageQueryProvider);
    final pageError = ref.read(pageErrorProvider.state);
    final activeServer = ref.read(activeServerProvider);
    final safeMode = ref.read(safeModeProvider);
    final blockedTags = ref.read(blockedTagsProvider);
    final postLimit = ref.read(serverPostLimitProvider);

    if (query != null && pageQuery != query) {
      ref.read(pageQueryProvider.notifier).state = query;
      ref.read(searchHistoryProvider).push(query);
    }

    if (clear) posts.clear();
    if (posts.isEmpty) _page = 0;
    pageLoading.state = true;
    pageError.state = [];
    try {
      final url = activeServer.searchUrlOf(
        query ?? pageQuery,
        _page,
        safeMode,
        postLimit,
      );
      Fimber.d('Fetching $url');
      final res = await retryFuture(
        () => http.get(Uri.parse(url)).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final data = ServerResponseParser.parsePage(activeServer, res);
      posts.addAll(data.where((it) =>
          !it.tags.any(blockedTags.listedEntries.contains) &&
          !posts.any((post) => post.id == it.id)));
    } catch (exception, stackTrace) {
      if (exception is SphereException) {
        final message = _buildErrorMessage(exception.message);
        pageError.state = [exception.copyWith(message: message), stackTrace];
      } else {
        pageError.state = [exception, stackTrace];
      }
    }

    pageLoading.state = false;
  }

  void loadMore() {
    final pageLoading = ref.read(pageLoadingProvider);
    final pageError = ref.read(pageErrorProvider);
    if (pageError.isEmpty && !pageLoading) {
      _page++;
      fetch();
    }
  }

  void initialize() async {
    final serverData = ref.read(serverDataProvider.notifier);

    await serverData.populateData();
    ref.read(activeServerProvider.notifier).restore(serverData);

    posts.clear();
    fetch();
  }
}
