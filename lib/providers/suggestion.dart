import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../data/sphere_exception.dart';
import '../utils/map_ext.dart';
import '../utils/retry_future.dart';
import '../utils/string_ext.dart';
import 'blocked_tags.dart';
import 'settings/active_server.dart';

final suggestionProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  if (query.endsWith(' ')) {
    return [];
  }

  final manager = SuggestionManager(ref);
  return await manager.fetch(query: query);
});

class SuggestionManager {
  SuggestionManager(this.ref);

  final Ref ref;

  List<String> parse(http.Response res, String query) {
    final blockedTags = ref.read(blockedTagsProvider);

    if (res.statusCode != 200) {
      throw SphereException(
          message: 'Cannot fetch data (HTTP ${res.statusCode})');
    }

    final noTagsError =
        SphereException(message: 'No tags that matches \'$query\'');

    List<dynamic> entries = [];
    if (res.body.contains(RegExp('[a-z][\'"]s*:'))) {
      entries = res.body.contains('@attributes')
          ? jsonDecode(res.body)['tag']
          : jsonDecode(res.body);
    } else if (res.body.isEmpty) {
      return [];
    } else if (res.body.contains('<?xml')) {
      final xjson = Xml2Json();
      xjson.parse(res.body.replaceAll('\\', ''));

      final jsonObj = jsonDecode(xjson.toGData());
      if (!jsonObj.values.first.keys.contains('tag')) {
        throw noTagsError;
      }

      final tags = jsonObj.values.first['tag'];
      if (tags is LinkedHashMap) {
        entries = [tags];
      } else if (tags is List) {
        entries = tags;
      } else {
        throw noTagsError;
      }
    } else {
      throw noTagsError;
    }

    final result = <String>[];
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.take(['name', 'tag'], orElse: '');
      final postCount = entry.take(['post_count', 'count'], orElse: 0);
      if (!blockedTags.listedEntries.contains(tag) && postCount > 0) {
        result.add(tag);
      }
    }

    return result;
  }

  Future<List<String>> fetch({required String query}) async {
    final queries = query.trim().split(' ');
    final activeServer = ref.read(activeServerProvider);

    final url = activeServer.suggestionUrlOf(queries.last);
    try {
      final res = await retryFuture(
        () => http.get(url.asUri).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      return parse(res, query)
          .where((it) =>
              it.contains(queries.last) &&
              !queries.sublist(0, queries.length - 1).contains(it))
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
