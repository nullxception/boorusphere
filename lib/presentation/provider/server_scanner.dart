import 'dart:async';

import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_scanner.g.dart';

@riverpod
ServerScanner serverScanner(ServerScannerRef ref) {
  return ServerScanner(ref.watch(dioProvider));
}

enum _PayloadType {
  search,
  suggestion,
  post,
}

class _Payload {
  const _Payload({
    required this.result,
    required this.type,
  });

  final _ScanResult result;
  final _PayloadType type;
}

class _ScanResult {
  const _ScanResult({
    this.origin = '',
    this.query = '',
  });

  final String origin;
  final String query;

  static const empty = _ScanResult();
}

class ServerScanner {
  ServerScanner(this.client);

  final Dio client;

  late CancelToken _cancelToken = CancelToken();

  Future<_ScanResult> _tryQuery(
    String host,
    String query,
    _PayloadType type,
  ) async {
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
        cancelToken: _cancelToken,
      );

      final origin = res.redirects.isNotEmpty && res.realUri.hasAuthority
          ? res.realUri.origin
          : host;

      if (type == _PayloadType.post) {
        return _ScanResult(origin: origin, query: query);
      }

      final contentType = res.headers['content-type'] ?? [];
      if (contentType.any((it) => it.contains(RegExp(r'(json|xml)'))) &&
          res.data.toString().isEmpty) {
        return _ScanResult.empty;
      }

      return _ScanResult(
        origin: origin,
        query: contentType.any((it) => it.contains('html')) ? '' : query,
      );
    } on DioError {
      return _ScanResult.empty;
    }
  }

  Future<_Payload> _test(
    String host,
    List<String> queries,
    _PayloadType type,
  ) async {
    final result = await Future.wait<_ScanResult>(
      queries.map((q) => _tryQuery(host, q, type)),
    );

    return _Payload(
      result: result.firstWhere(
        (it) => it.query.isNotEmpty,
        orElse: () => _ScanResult(origin: host),
      ),
      type: type,
    );
  }

  void cancel() {
    _cancelToken.cancel();
    _cancelToken = CancelToken();
  }

  Future<ServerData> scan(String homeUrl, String apiUrl) async {
    final api = apiUrl.replaceFirst(RegExp(r'/$'), '');
    final home = homeUrl.replaceFirst(RegExp(r'/$'), '');

    final tests = await Future.wait([
      _test(api, searchQueries, _PayloadType.search),
      _test(api, suggestionQueries, _PayloadType.suggestion),
      _test(home, webPostUrls, _PayloadType.post),
    ]);

    return tests.fold<ServerData>(
      ServerData(id: home.toUri().host),
      (prev, it) {
        switch (it.type) {
          case _PayloadType.search:
            return prev.copyWith(
              searchUrl: it.result.query,
              apiAddr: it.result.origin,
            );
          case _PayloadType.suggestion:
            return prev.copyWith(
              tagSuggestionUrl: it.result.query,
              apiAddr: it.result.origin,
            );
          case _PayloadType.post:
            return prev.copyWith(
              postUrl: it.result.query,
              homepage: it.result.origin,
            );
        }
      },
    );
  }

  static const searchQueries = [
    // JSON
    'post.json?tags={tags}&page={page-id}&limit={post-limit}',
    'posts.json?tags={tags}&page={page-id}&limit={post-limit}',
    'post/index.json?limit={post-limit}&page={page-id}&tags={tags}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}&json=1',
    // XML
    'api/danbooru/find_posts/index.xml?tags={tags}&limit={post-limit}&page={page-id}',
    'post/index.xml?limit={post-limit}&page={page-id}&tags={tags}',
    'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}',
  ];

  static const suggestionQueries = [
    // JSON
    'tag.json?name=*{tag-part}*&order=count&limit={post-limit}',
    'tags.json?search[name_matches]=*{tag-part}*&search[order]=count&limit={post-limit}',
    'tag/index.json?name=*{tag-part}*&order=count&limit={post-limit}',
    'index.php?page=dapi&s=tag&q=index&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}&json=1',
    // XML
    'api/internal/autocomplete?s={tag-part}',
    'tag/index.xml?name=*{tag-part}*&order=count&limit={post-limit}',
    'index.php?page=dapi&s=tag&q=index&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}',
  ];

  static const webPostUrls = [
    'posts/{post-id}',
    'post/show/{post-id}',
    'post/view/{post-id}',
    'index.php?page=post&s=view&id={post-id}',
  ];
}
