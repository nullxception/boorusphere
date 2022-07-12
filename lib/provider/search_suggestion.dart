import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../util/map_utils.dart';
import 'blocked_tags.dart';
import 'server_data.dart';

final searchSuggestionProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  final handler = SearchSuggestionHandler(ref.read);
  return await handler.fetch(query: query);
});

class SearchSuggestionHandler {
  final Reader read;

  SearchSuggestionHandler(this.read);

  Future<List<String>> _parse(http.Response res) async {
    final blockedTags = read(blockedTagsProvider);
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
    } else {
      throw const FormatException('Unknown document format');
    }

    final result = <String>[];
    for (final Map<String, dynamic> entry in entries) {
      final tags = MapUtils.findEntry(entry, '^(name|tag)');
      final postCount = MapUtils.getInt(entry, '.*count');
      if (postCount > 0 && !blocked.contains(tags.value)) {
        result.add(tags.value);
      }
    }

    return result;
  }

  Future<List<String>> fetch({required String query}) async {
    if (query.endsWith(' ')) {
      return [];
    }

    final queries = query.trim().split(' ');
    final server = read(serverDataProvider);
    try {
      final res =
          await http.get(server.active.composeSuggestionUrl(queries.last));
      final tags = await _parse(res);
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
