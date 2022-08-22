import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../entity/server_data.dart';
import '../../entity/server_payload.dart';
import '../extensions/string.dart';
import '../retry_future.dart';

class ServerScanner {
  static Future<ServerPayload> _testPayload(
    Dio client,
    String host,
    List<String> queries,
    ServerPayloadType type,
  ) async {
    final result = await Future.wait(
      queries.map((query) async {
        final test = query
            .replaceAll('{tags}', '*')
            .replaceAll('{tag-part}', 'a')
            .replaceAll('{post-limit}', '3')
            .replaceAll('{page-id}', '1')
            .replaceAll('{post-id}', '100');
        final res = await retryFuture(
          () => client.get('$host/$test').timeout(const Duration(seconds: 5)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );

        if (res.statusCode != 200) return '';
        if (type == ServerPayloadType.post) return query;
        final contentType = res.headers['content-type'] ?? [];
        return contentType.any((it) => it.contains('html')) ? '' : query;
      }),
    );

    return ServerPayload(
      host: host,
      query: result.firstWhere((it) => it.isNotEmpty, orElse: () => ''),
      type: type,
    );
  }

  static Future<ServerData> scan(
    Dio client,
    String homeUrl,
    String apiUrl,
  ) async {
    String post = '', search = '', suggestion = '';
    final tests = await Future.wait(
      [
        _testPayload(
          client,
          apiUrl,
          searchQueries,
          ServerPayloadType.search,
        ),
        _testPayload(
          client,
          apiUrl,
          suggestionQueries,
          ServerPayloadType.suggestion,
        ),
        _testPayload(
          client,
          homeUrl,
          webPostUrls,
          ServerPayloadType.post,
        ),
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
      name: homeUrl.asUri.host,
      homepage: homeUrl,
      postUrl: post,
      searchUrl: search,
      tagSuggestionUrl: suggestion,
      apiAddr: apiUrl,
    );
  }

  static const searchQueries = [
    'post.json?tags={tags}&page={page-id}&limit={post-limit}',
    'posts.json?tags={tags}&page={page-id}&limit={post-limit}',
    'post/index.json?limit={post-limit}&page={page-id}&tags={tags}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}&json=1',
    'post/index.xml?limit={post-limit}&page={page-id}&tags={tags}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}',
  ];

  static const suggestionQueries = [
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
