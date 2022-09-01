import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/extensions/string.dart';
import '../../utils/server/response_parser.dart';
import '../entity/server_data.dart';
import '../services/http.dart';
import 'blocked_tags.dart';
import 'settings/server/active.dart';

final _dataSource = Provider(SuggestionSource.new);
final suggestionFuture = FutureProvider.autoDispose
    .family<Iterable<String>, String>((ref, query) async {
  final serverActive = ref.watch(serverActiveProvider);
  if (serverActive == ServerData.empty) {
    return {};
  }

  final source = ref.watch(_dataSource);
  return await source.fetch(query: query, server: serverActive);
});

class SuggestionSource {
  SuggestionSource(this.ref);

  final Ref ref;

  Future<Iterable<String>> fetch({
    required String query,
    required ServerData server,
  }) async {
    final blockedTags = ref.read(blockedTagsProvider);
    final client = ref.read(httpProvider);

    final queries = query.toWordList();
    final word = queries.isEmpty ? '' : queries.last;
    final urls = server.suggestionUrlsOf(word);
    try {
      final res = await Future.wait(urls.map(client.get));
      return res
          .map((e) => ServerResponseParser.parseTagSuggestion(e, query))
          .reduce((value, element) => {...value, ...element})
          .where((it) => !blockedTags.values.contains(it))
          .sortedByCompare<String>(
        (element) => element,
        (a, b) {
          if (a.startsWith(word)) return -1;
          if (a.endsWith(word)) return 0;
          return 1;
        },
      );
    } catch (e) {
      if (query.isEmpty) {
        // the server did not support empty tag matches (hot/trending tags)
        return [];
      }
      rethrow;
    }
  }
}
