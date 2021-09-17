import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../util/map_utils.dart';
import 'blocked_tags.dart';
import 'server_data.dart';

final typedSearchBarQueryProvider = StateProvider((ref) => '');
final searchSuggestionProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final handler = SearchSuggestionHandler(ref.read);
  final typedData = ref.watch(typedSearchBarQueryProvider).state;
  final last = typedData.trim().split(' ').last.trim();
  if (typedData.endsWith(' ') && last.length <= 2) {
    return [];
  }

  return await handler.fetch(query: typedData);
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
    if (res.body.contains(RegExp('[a-z][\'"]\s*:'))) {
      entries = jsonDecode(res.body);
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
      throw Exception('No tag that matches "$query"');
    } on Exception catch (e) {
      Fimber.e('Something went wrong', ex: e);
      rethrow;
    }
  }
}
