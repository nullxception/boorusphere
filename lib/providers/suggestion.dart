import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../utils/extensions/string.dart';
import '../utils/retry_future.dart';
import '../utils/server/response_parser.dart';
import 'blocked_tags.dart';
import 'settings/active_server.dart';

final suggestionProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  final manager = SuggestionManager(ref);
  return await manager.fetch(query: query);
});

class SuggestionManager {
  SuggestionManager(this.ref);

  final Ref ref;

  Future<List<String>> fetch({required String query}) async {
    final activeServer = ref.read(activeServerProvider);
    final blockedTags = ref.read(blockedTagsProvider);

    final url = activeServer.suggestionUrlOf(query.split(' ').last);
    try {
      final res = await retryFuture(
        () => http.get(url.asUri).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      return ServerResponseParser.parseTagSuggestion(res, query)
          .where((it) => !blockedTags.listedEntries.contains(it))
          .toList();
    } catch (e) {
      if (query.isEmpty) {
        // the server did not support empty tag matches (hot/trending tags)
        return [];
      }
      rethrow;
    }
  }
}
