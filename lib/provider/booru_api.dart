import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

class BooruApi {
  BooruApi(this.read);

  final Reader read;
  final List<BooruPost> posts = [];

  int _page = 1;

  Future<List<BooruPost>> _parseHttpResponse(http.Response res) async {
    final booruQuery = read(booruQueryProvider);
    final blockedTags = read(blockedTagsProvider);
    final blocked = await blockedTags.listedEntries;

    if (res.statusCode != 200) {
      throw HttpException('Something went wrong [${res.statusCode}]');
    } else if (!res.body.contains(RegExp('https?:\/\/.*'))) {
      // no url founds in the document means no image(s) available to display
      throw HttpException(posts.isNotEmpty
          ? 'No more result for "${booruQuery.tags}"'
          : 'No result for "${booruQuery.tags}"');
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
      final id = MapUtils.getInt(post, r'^id$');
      final src = MapUtils.getUrl(post, '^(file_url|url)');
      final displaySrc = MapUtils.getUrl(post, '^large_file');
      final thumbnail = MapUtils.getUrl(post, '^(preview_fi|preview)');
      final tags = MapUtils.findEntry(post, '^(tags|tag_str)');
      final width = MapUtils.getInt(post, '^(image_wid|width)');
      final height = MapUtils.getInt(post, '^(image_hei|height)');
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

  void fetch() async {
    final pageLoading = read(pageLoadingProvider);
    final booruQuery = read(booruQueryProvider);
    final server = read(serverDataProvider);
    final errorMessage = read(pageErrorProvider);

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
      final res = await http.get(url);
      final data = await _parseHttpResponse(res);
      posts.addAll(data);
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      errorMessage.state = _parseException(e);
    } finally {
      pageLoading.state = false;
    }
  }

  void loadMore() {
    final pageLoading = read(pageLoadingProvider);
    if (!pageLoading.state) {
      _page++;
      fetch();
    }
  }

  Future<ServerPayload> _queryTest(
      String url, List<String> queries, ServerPayloadType type) async {
    String? result;
    await Future.wait(queries.map((it) async {
      final query = it
          .replaceAll('{q}', type == ServerPayloadType.suggestion ? 'a' : '*')
          .replaceAll('{l}', '3')
          .replaceAll('{p}', '1')
          .replaceAll('{id}', '100');
      final res = await http.get(Uri.parse('$url/$query'));
      if (res.statusCode == 200) {
        result = it;
      }
    }));
    return ServerPayload(host: url, query: result, type: type);
  }

  Future<ServerData> scanServerUrl(String url) async {
    final tests = await Future.wait(
      [
        _queryTest(url, searchQueries, ServerPayloadType.search),
        _queryTest(url, tagSuggestionQueries, ServerPayloadType.suggestion),
        _queryTest(url, webPostUrls, ServerPayloadType.post),
      ],
    );
    var post, search, suggestion;
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

  static const searchQueries = [
    'post.json?tags={q}&page={p}&limit={l}',
    'posts.json?tags={q}&page={p}&limit={l}',
    'index.php?page=dapi&s=post&q=index&tags={q}&pid={p}&limit={l}',
  ];

  static const tagSuggestionQueries = [
    'tag.json?name=*{q}*&order=count&limit={l}',
    'tags.json?search[name_matches]=*{q}*&search[order]=count&limit={l}',
    'index.php?page=dapi&s=tag&q=index&json=1&name_pattern=%{q}%&orderby=count&limit={l}',
  ];

  static const webPostUrls = [
    'posts/{id}',
    'index.php?page=post&s=view&id={id}',
    'post/show/{id}',
  ];
}

final booruApiProvider = Provider((ref) => BooruApi(ref.read));
