import 'dart:async';

import 'package:boorusphere/data/entity/server_data.dart';
import 'package:boorusphere/data/entity/sphere_exception.dart';
import 'package:boorusphere/data/services/http.dart';
import 'package:boorusphere/data/source/api/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/source/api/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/source/api/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/source/api/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/source/api/parser/safebooruxml_parser.dart';
import 'package:boorusphere/data/source/blocked_tags.dart';
import 'package:boorusphere/data/source/settings/server/active.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Set<String> _parse(ServerData server, Response res, String query) {
    if (res.statusCode != 200) {
      throw SphereException(
          message: 'Cannot fetch data (HTTP ${res.statusCode})');
    }

    final parser = [
      DanbooruJsonParser(server),
      KonachanJsonParser(server),
      GelbooruXmlParser(server),
      GelbooruJsonParser(server),
      SafebooruXmlParser(server),
    ];

    try {
      return parser
          .firstWhere((it) => it.canParseSuggestion(res))
          .parseSuggestion(res);
    } on StateError {
      throw SphereException(message: 'No tags that matches \'$query\'');
    }
  }

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
          .map((e) => _parse(server, e, query))
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
