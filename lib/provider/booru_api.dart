import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:xml2json/xml2json.dart';

import '../model/booru_post.dart';
import '../model/server_data.dart';
import '../model/server_payload.dart';
import '../util/map_ext.dart';
import 'blocked_tags.dart';
import 'booru_query.dart';
import 'server_data.dart';
import 'settings/active_server.dart';

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

    final idKey = ['id'];
    final originalFileKey = ['file_url'];
    final sampleFileKey = ['large_file_url', 'sample_url'];
    final previewFileKey = ['preview_url', 'preview_file_url'];
    final tagsKey = ['tags', 'tag_string'];
    final widthKey = ['image_width', 'width'];
    final heightKey = ['image_height', 'height'];
    final sampleWidthKey = ['sample_width'];
    final sampleHeightKey = ['sample_height'];
    final previewWidthKey = ['preview_width'];
    final previewHeightKey = ['preview_height'];

    final ratingKey = ['rating'];

    for (final Map<String, dynamic> post in entries) {
      final id = post.take(idKey, orElse: -1);
      final originalFile = post.take(originalFileKey, orElse: '');
      final sampleFile = post.take(sampleFileKey, orElse: '');
      final previewFile = post.take(previewFileKey, orElse: '');
      final tags = post.take(tagsKey, orElse: <String>[]);
      final width = post.take(widthKey, orElse: -1);
      final height = post.take(heightKey, orElse: -1);
      final sampleWidth = post.take(sampleWidthKey, orElse: -1);
      final sampleHeight = post.take(sampleHeightKey, orElse: -1);
      final previewWidth = post.take(previewWidthKey, orElse: -1);
      final previewHeight = post.take(previewHeightKey, orElse: -1);
      final rating = post.take(ratingKey, orElse: 'q');

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final notBlocked = !tags.any(blocked.contains);
      final postUrl = id < 0 ? '' : _composePostUrl(server, id);

      if (hasFile && hasContent && notBlocked) {
        result.add(
          BooruPost(
            id: id,
            originalFile: originalFile,
            sampleFile: sampleFile,
            previewFile: previewFile,
            tags: tags,
            width: width,
            height: height,
            sampleWidth: sampleWidth,
            sampleHeight: sampleHeight,
            previewWidth: previewWidth,
            previewHeight: previewHeight,
            serverName: server.name,
            postUrl: postUrl,
            rateValue: rating.isEmpty ? 'q' : rating,
          ),
        );
      }
    }

    return result;
  }

  String _composePostUrl(ServerData server, int id) {
    if (server.postUrl.isEmpty) {
      return '';
    }

    final query = server.postUrl.replaceAll('{post-id}', id.toString());
    return '${server.homepage}/$query';
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
    final errorMessage = read(pageErrorProvider.state);
    final activeServer = read(activeServerProvider);

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
      final url = activeServer.composeSearchUrl(booruQuery, _page);
      Fimber.d('Fetching $url');
      final res = await rere(
        () => http.get(url).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final data = await _parseQueryResponse(activeServer, res);
      posts.addAll(data);
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      final msg = _getExceptionMessage(e);
      errorMessage.state = booruQuery.safeMode ? '(Safe Mode) $msg' : msg;
    }

    pageLoading.state = false;
  }

  void loadMore() {
    final pageLoading = read(pageLoadingProvider);
    final pageError = read(pageErrorProvider);
    if (pageError.isEmpty && !pageLoading) {
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

        if (res.statusCode != 200) return '';
        if (type == ServerPayloadType.post) return query;
        final contentType = res.headers['content-type'] ?? '';

        return contentType.contains('html') ? '' : query;
      }),
    );

    return ServerPayload(
        host: host,
        query: result.firstWhere((it) => it.isNotEmpty, orElse: () => ''),
        type: type);
  }

  Future<ServerData> scanServerUrl(String url) async {
    String post = '', search = '', suggestion = '';
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

    return ServerData(
        name: Uri.parse(url).host,
        homepage: url,
        postUrl: post,
        searchUrl: search,
        tagSuggestionUrl: suggestion);
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

  Future<List<String>> fetchSuggestion({required String query}) async {
    final queries = query.trim().split(' ');
    final activeServer = read(activeServerProvider);

    try {
      final url = activeServer.composeSuggestionUrl(queries.last);
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

  void initialize() async {
    final serverDataNotifier = read(serverDataProvider.notifier);
    final activeServerNotifier = read(activeServerProvider.notifier);

    await serverDataNotifier.populateData();
    await activeServerNotifier.restoreFromPreference();

    posts.clear();
    fetch();
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
    'index.php?page=dapi&s=tag&q=index&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}',
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
