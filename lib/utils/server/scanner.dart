import 'dart:async';

import 'package:boorusphere/entity/server_data.dart';
import 'package:boorusphere/entity/server_payload.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';

class ServerScanner {
  static Future<ServerPayload> _testPayload(
    Dio client,
    String host,
    List<String> queries,
    ServerPayloadType type,
  ) async {
    final result = await Future.wait<ServerScanResult>(
      queries.map((query) async {
        final test = query
            .replaceAll('{tags}', '*')
            .replaceAll('{tag-part}', 'a')
            .replaceAll('{post-limit}', '3')
            .replaceAll('{page-id}', '1')
            .replaceAll('{post-id}', '100');
        try {
          final res = await client.get(
            '$host/$test',
            options: Options(validateStatus: (it) => it == 200),
          );
          final origin = res.redirects.isNotEmpty
              ? res.redirects.last.location.origin
              : host;

          if (type == ServerPayloadType.post) {
            return ServerScanResult(origin: origin, query: query);
          }

          final contentType = res.headers['content-type'] ?? [];
          return ServerScanResult(
            origin: origin,
            query: contentType.any((it) => it.contains('html')) ? '' : query,
          );
        } on DioError {
          return ServerScanResult.empty;
        }
      }),
    );

    return ServerPayload(
      result: result.firstWhere(
        (it) => it.query.isNotEmpty,
        orElse: () => ServerScanResult(origin: host),
      ),
      type: type,
    );
  }

  static Future<ServerData> scan(
    Dio client,
    String homeUrl,
    String apiUrl,
  ) async {
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

    return tests.fold<ServerData>(
      ServerData(id: homeUrl.asUri.host),
      (prev, it) {
        switch (it.type) {
          case ServerPayloadType.search:
            return prev.copyWith(
              searchUrl: it.result.query,
              apiAddr: it.result.origin,
            );
          case ServerPayloadType.suggestion:
            return prev.copyWith(
              tagSuggestionUrl: it.result.query,
              apiAddr: it.result.origin,
            );
          case ServerPayloadType.post:
            return prev.copyWith(
              postUrl: it.result.query,
              homepage: it.result.origin,
            );
        }
      },
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
