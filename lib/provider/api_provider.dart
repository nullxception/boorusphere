import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../model/booru_post.dart';
import '../model/server_query.dart';
import 'common.dart';

final _pageNumberProvider = StateProvider((_) => 1);

class ApiProvider {
  final Reader read;

  ApiProvider(this.read) {
    _init();
  }

  void _init() async {
    final server = read(serverProvider);
    final safeMode = read(safeModeProvider.notifier);

    await server.init();
    await safeMode.init();
    fetch(clear: true);
  }

  MapEntry<String, dynamic> _getEntry(Map<String, dynamic> data, String key) {
    return data.entries.firstWhere(
      (e) => e.key.contains(RegExp(key)),
      orElse: () => const MapEntry('', null),
    );
  }

  String? _parseJsonLink(Map<String, dynamic> data, String key) {
    final result = _getEntry(data, key).value;
    if (result is String && result.contains(RegExp('https?:\/\/.*'))) {
      return result;
    } else {
      return null;
    }
  }

  int _parseJsonNumber(Map<String, dynamic> data, String key) {
    final result = _getEntry(data, key);
    if (result.value is int) {
      return result.value;
    } else if (result.value is String) {
      return int.parse(result.value);
    } else {
      return 0;
    }
  }

  Future<List<BooruPost>> _parseHttpResponse(http.Response res) async {
    final booruPosts = read(booruPostsProvider);
    final searchTag = read(searchTagProvider);
    final blockedTags = read(blockedTagsProvider);
    final blocked = await blockedTags.listedEntries;

    if (res.statusCode != 200) {
      throw HttpException('Something went wrong [${res.statusCode}]');
    } else if (!res.body.contains(RegExp('https?:\/\/.*'))) {
      // no url founds in the document means no image(s) available to display
      throw HttpException(booruPosts.isNotEmpty
          ? 'No more result for "$searchTag"'
          : 'No result for "$searchTag"');
    }

    List<dynamic> entries;
    if (res.body.contains(RegExp('[a-z][\'"]\s*:'))) {
      // json body, like on danbooru or yandere
      entries = jsonDecode(res.body);
    } else if (res.body.startsWith('<?xm')) {
      // xml body, like safebooru for example
      final xjson = Xml2Json();
      xjson.parse(res.body.replaceAll('\\', ''));

      final jsonObj = jsonDecode(xjson.toGData());
      if (jsonObj.values.first.keys.contains('post')) {
        entries = jsonObj.values.first['post'];
      } else {
        throw const FormatException('Unknown document format');
      }
    } else {
      throw const FormatException('Unknown document format');
    }

    final result = <BooruPost>[];
    for (final Map<String, dynamic> post in entries) {
      final id = _parseJsonNumber(post, r'^id$');
      final src = _parseJsonLink(post, '^(file_url|url)');
      final displaySrc = _parseJsonLink(post, '^large_file');
      final thumbnail = _parseJsonLink(post, '^(preview_fi|preview)');
      final tags = _getEntry(post, '^(tags|tag_str)');
      final width = _parseJsonNumber(post, '^(image_wid|width)');
      final height = _parseJsonNumber(post, '^(image_hei|height)');
      final tagList = tags.value.toString().trim().split(' ');

      final hasContent = width > 0 && height > 0;
      final notBlocked = !tagList.any(blocked.contains);

      if (src != null && thumbnail != null && hasContent && notBlocked) {
        result.add(
          BooruPost(
            id: id,
            src: src,
            displaySrc: displaySrc ?? src,
            thumbnail: thumbnail,
            tags: tagList,
            width: width,
            height: height,
          ),
        );
      }
    }

    return result;
  }

  Future<Either<Exception, List<BooruPost>>> _fetch(ServerQuery query) async {
    final server = read(serverProvider);
    try {
      final res = await http.get(server.active.composeSearchUrl(query));
      final data = await _parseHttpResponse(res);
      return right(data);
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      return left(e);
    }
  }

  String _parseException(Exception fail) {
    try {
      final message = fail
          .toString()
          .split(':')
          .skipWhile((it) => it.contains(RegExp(r'xception$')))
          .join(':')
          .trim();

      if (message.isNotEmpty) {
        return message;
      } else {
        throw Exception('An empty exception was throwed');
      }
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      return 'Something went wrong';
    }
  }

  Future<List<String>> _parseSuggestionTags(http.Response res) async {
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
      final tags = _getEntry(entry, '^(name|tag)');
      final postCount = _parseJsonNumber(entry, '.*count');
      if (postCount > 0 && !blocked.contains(tags.value)) {
        result.add(tags.value);
      }
    }

    return result;
  }

  Future<List<String>> fetchSuggestion({required String query}) async {
    final queries = query.trim().split(' ');
    final last = queries.last.trim();

    // Filter the query, it must be longer than 2
    if (query.endsWith(' ') || last.length < 2) {
      return [];
    }

    final server = read(serverProvider);
    if (!server.active.canSuggestTags) {
      Fimber.w('No search suggestion feature on ${server.active.name}');
      return [];
    }

    try {
      final res = await http.get(server.active.composeSuggestionUrl(last));
      final tags = await _parseSuggestionTags(res);
      return tags
          .where((it) =>
              it.contains(last) &&
              !queries.sublist(0, queries.length - 1).contains(it))
          .toList();
    } on Exception catch (e) {
      Fimber.e('Something went wrong', ex: e);
      return [];
    }
  }

  Future<void> fetch({bool clear = false}) async {
    final page = read(_pageNumberProvider);
    final pageLoading = read(pageLoadingProvider);
    final searchTag = read(searchTagProvider);
    final safeMode = read(safeModeProvider);
    final errorMessage = read(errorMessageProvider);
    final booruPosts = read(booruPostsProvider);

    if (clear && page.state > 1) {
      page.state = 1;
    } else if (!clear) {
      page.state++;
    }
    if (!pageLoading.state) {
      pageLoading.state = true;
    }
    if (errorMessage.state.isNotEmpty) {
      errorMessage.state = '';
    }
    if (clear && booruPosts.isNotEmpty) {
      booruPosts.clear();
    }

    final res = await _fetch(
      ServerQuery(page: page.state, tags: searchTag, safeMode: safeMode),
    );
    res.fold(
      (fail) => errorMessage.state = _parseException(fail),
      booruPosts.addAll,
    );
    pageLoading.state = false;
  }

  void loadMore() {
    final pageLoading = read(pageLoadingProvider);
    if (!pageLoading.state) {
      fetch();
    }
  }
}
