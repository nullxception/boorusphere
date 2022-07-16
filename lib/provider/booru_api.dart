import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:xml2json/xml2json.dart';

import '../model/booru_post.dart';
import '../model/server_data.dart';
import '../model/server_payload.dart';
import '../util/map_utils.dart';
import 'blocked_tags.dart';
import 'booru_query.dart';
import 'server_data.dart';

final pageLoadingProvider = StateProvider((_) => false);
final pageErrorProvider = StateProvider((_) => '');
final rere = const RetryOptions(maxAttempts: 4).retry;

class BooruApi {
  BooruApi(this.read);

  final Reader read;
  final List<BooruPost> posts = [];

  int _page = 1;

  Future<List<BooruPost>> _parseQueryResponse(
      ServerData server, http.Response res) async {
    final booruQuery = read(booruQueryProvider);
    final blockedTags = read(blockedTagsProvider);
    final blocked = await blockedTags.listedEntries;

    if (res.statusCode != 200) {
      throw HttpException('Something went wrong [${res.statusCode}]');
    } else if (!res.body.contains(RegExp('https?'))) {
      // no url founds in the document means no image(s) available to display
      throw HttpException(posts.isNotEmpty
          ? 'No more result for "${booruQuery.tags}"'
          : 'No result for "${booruQuery.tags}"');
    }

    List<dynamic> entries;
    if (res.body.contains(RegExp('[a-z][\'"]s*:'))) {
      entries = res.body.contains('@attributes')
          ? jsonDecode(res.body)['post']
          : jsonDecode(res.body);
    } else if (res.body.contains('<?xml')) {
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
      final id = MapUtils.getInt(post, r'^id$');
      final src = MapUtils.getUrl(post, '^(file_url|url)');
      final displaySrc = MapUtils.getUrl(post, '^large_file');
      final thumbnail =
          MapUtils.getUrl(post, '^(preview_url|preview_file|preview)');
      final tags = MapUtils.getWordlist(post, '^(tags|tag_str)');
      final width = MapUtils.getInt(post, '^(image_wi|preview_wi|width)');
      final height = MapUtils.getInt(post, '^(image_he|preview_he|height)');

      final hasContent = width > 0 && height > 0;
      final notBlocked = !tags.any(blocked.contains);

      if (src.isNotEmpty && thumbnail.isNotEmpty && hasContent && notBlocked) {
        result.add(
          BooruPost(
            id: id,
            src: src,
            displaySrc: displaySrc.isEmpty ? src : displaySrc,
            thumbnail: thumbnail,
            tags: tags,
            width: width,
            height: height,
            serverName: server.name,
          ),
        );
      }
    }

    return result;
  }

  String _getExceptionMessage(Exception e) => e
      .toString()
      .split(':')
      .skipWhile((it) => it.contains(RegExp(r'xception$')))
      .join(':')
      .trim();

  void fetch() async {
    final pageLoading = read(pageLoadingProvider.state);
    final booruQuery = read(booruQueryProvider);
    final server = read(serverDataProvider);
    final errorMessage = read(pageErrorProvider.state);

    if (posts.isEmpty) {
      _page = 1;
    }
    if (!pageLoading.state) {
      pageLoading.state = true;
    }
    if (errorMessage.state.isNotEmpty) {
      errorMessage.state = '';
    }

    try {
      final url = server.active.composeSearchUrl(booruQuery, _page);
      Fimber.d('Fetching $url');
      final res = await rere(
        () => http.get(url).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final data = await _parseQueryResponse(server.active, res);
      posts.addAll(data);
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      final msg = _getExceptionMessage(e);
      errorMessage.state = booruQuery.safeMode ? '(Safe Mode) $msg' : msg;
    }

    pageLoading.state = false;
  }

  void loadMore() {
    final pageLoading = read(pageLoadingProvider.state);
    if (!pageLoading.state) {
      _page++;
      fetch();
    }
  }

  Future<ServerPayload> _queryTest(
      String host, List<String> queries, ServerPayloadType type) async {
    final result = await Future.wait(
      queries.map((query) async {
        final test = query
            .replaceAll('{tags}', '*')
            .replaceAll('{tag-part}', 'a')
            .replaceAll('{post-limit}', '3')
            .replaceAll('{page-id}', '1')
            .replaceAll('{post-id}', '100');
        final url = Uri.parse('$host/$test');
        final res = await rere(
          () => http.get(url).timeout(const Duration(seconds: 5)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );

        return res.statusCode == 200 ? query : '';
      }),
    );

    return ServerPayload(
        host: host,
        query: result.firstWhere((it) => it.isNotEmpty, orElse: () => ''),
        type: type);
  }

  Future<Either<Exception, ServerData>> scanServerUrl(String url) async {
    String post = '', search = '', suggestion = '';
    try {
      final tests = await Future.wait(
        [
          _queryTest(url, searchQueries, ServerPayloadType.search),
          _queryTest(url, tagSuggestionQueries, ServerPayloadType.suggestion),
          _queryTest(url, webPostUrls, ServerPayloadType.post),
        ],
      );

      for (final payload in tests) {
        switch (payload.type) {
          case ServerPayloadType.search:
            search = payload.query;
            break;
          case ServerPayloadType.suggestion:
            suggestion = payload.query;
            break;
          case ServerPayloadType.post:
            post = payload.query;
            break;
          default:
            break;
        }
      }
    } on Exception catch (e) {
      return Left(e);
    }

    return Right(ServerData(
        name: Uri.parse(url).host,
        homepage: url,
        postUrl: post,
        searchUrl: search,
        tagSuggestionUrl: suggestion));
  }

  Future<List<String>> _parseSuggestion(http.Response res) async {
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

  Future<List<String>> fetchSuggestion({required String query}) async {
    final queries = query.trim().split(' ');
    final server = read(serverDataProvider);
    try {
      final url = server.active.composeSuggestionUrl(queries.last);
      final res = await rere(
        () => http.get(url).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final tags = await _parseSuggestion(res);
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

  static const searchQueries = [
    'post.json?tags={tags}&page={page-id}&limit={post-limit}',
    'posts.json?tags={tags}&page={page-id}&limit={post-limit}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}&json=1',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}',
  ];

  static const tagSuggestionQueries = [
    'tag.json?name=*{tag-part}*&order=count&limit={post-limit}',
    'tags.json?search[name_matches]=*{tag-part}*&search[order]=count&limit={post-limit}',
    'index.php?page=dapi&s=tag&q=index&json=1&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}',
  ];

  static const webPostUrls = [
    'posts/{post-id}',
    'index.php?page=post&s=view&id={post-id}',
    'post/show/{post-id}',
  ];
}

final booruApiProvider = Provider((ref) => BooruApi(ref.read));
final suggestionProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  if (query.endsWith(' ')) {
    return [];
  }

  final api = ref.read(booruApiProvider);
  return await api.fetchSuggestion(query: query);
});
