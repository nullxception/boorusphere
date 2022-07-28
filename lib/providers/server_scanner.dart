import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/server_data.dart';
import '../data/server_payload.dart';
import '../utils/retry_future.dart';
import '../utils/string_ext.dart';

final serverScannerProvider = Provider((ref) => ServerScanner(ref));

class ServerScanner {
  ServerScanner(this.ref);

  final Ref ref;

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
        final res = await retryFuture(
          () =>
              http.get('$host/$test'.asUri).timeout(const Duration(seconds: 5)),
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

  Future<ServerData> scan(String url) async {
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
        name: url.asUri.host,
        homepage: url,
        postUrl: post,
        searchUrl: search,
        tagSuggestionUrl: suggestion);
  }

  static const searchQueries = [
    'post.json?tags={tags}&page={page-id}&limit={post-limit}',
    'posts.json?tags={tags}&page={page-id}&limit={post-limit}',
    'post/index.json?limit={post-limit}&page={page-id}&tags={tags}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}&json=1',
    'post/index.xml?limit={post-limit}&page={page-id}&tags={tags}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}',
  ];

  static const tagSuggestionQueries = [
    'tag.json?name=*{tag-part}*&order=count&limit={post-limit}',
    'tags.json?search[name_matches]=*{tag-part}*&search[order]=count&limit={post-limit}',
    'tag/index.json?name=*{tag-part}*&order=count&limit={post-limit}',
    'index.php?page=dapi&s=tag&q=index&json=1&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}',
    'tag/index.xml?name=*{tag-part}*&order=count&limit={post-limit}',
    'index.php?page=dapi&s=tag&q=index&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}',
  ];

  static const webPostUrls = [
    'posts/{post-id}',
    'index.php?page=post&s=view&id={post-id}',
    'post/show/{post-id}',
  ];
}
