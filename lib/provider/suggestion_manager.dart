import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../util/map_ext.dart';
import '../util/retry_future.dart';
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

  Future<List<String>> parse(http.Response res) async {
    final blockedTags = ref.read(blockedTagsProvider);
    final blocked = await blockedTags.listedEntries;

    if (res.statusCode != 200) {
      throw HttpException('Something went wrong [${res.statusCode}]');
    }

    List<dynamic> entries;
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
      if (jsonObj.values.first.keys.contains('tag')) {
        entries = jsonObj.values.first['tag'];
      } else {
        throw const FormatException('Unknown document format');
      }
    } else {
      throw const FormatException('Unknown document format');
    }

    final result = <String>[];
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.take(['name', 'tag'], orElse: '');
      if (!blocked.contains(tag)) {
        result.add(tag);
      }
    }

    return result;
  }

  Future<List<String>> fetch({required String query}) async {
    final queries = query.trim().split(' ');
    final activeServer = ref.read(activeServerProvider);

    try {
      final url = activeServer.composeSuggestionUrl(queries.last);
      final res = await retryFuture(
        () => http.get(url).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final tags = await parse(res);
      return tags
          .where((it) =>
              it.contains(queries.last) &&
              !queries.sublist(0, queries.length - 1).contains(it))
          .toList();
    } on FormatException {
      if (query.isEmpty) {
        // the server did not support empty tag matches (hot/trending tags)
        return [];
      }

      throw Exception('No tag that matches "$query"');
    } on Exception catch (e) {
      Fimber.e('Something went wrong', ex: e);
      rethrow;
    }
  }
}
