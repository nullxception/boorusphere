import 'dart:async';

import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/booruonrailsjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmiexml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/szuruboorujson_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

enum _PayloadType {
  search,
  suggestion,
  post,
}

class _ScanResult {
  const _ScanResult({
    this.origin = '',
    this.parser = const NoParser(),
  });

  final String origin;
  final BooruParser parser;

  static const empty = _ScanResult();
}

class BooruScanner {
  BooruScanner(this.client);

  final Dio client;

  late CancelToken _cancelToken = CancelToken();

  final parsers = [
    KonachanJsonParser(ServerData.empty),
    DanbooruJsonParser(ServerData.empty),
    DanbooruV113JsonParser(),
    GelbooruJsonParser(ServerData.empty),
    BooruOnRailsJsonParser(ServerData.empty),
    SzurubooruJsonParser(ServerData.empty),
    ShimmieXmlParser(ServerData.empty),
    DanbooruV113XmlParser(),
    GelbooruXmlParser(ServerData.empty),
  ];

  Future<_ScanResult> _tryQuery(
    String host,
    BooruParser parser,
    _PayloadType type,
  ) async {
    final loadQuery = switch (type) {
      _PayloadType.post => parser.postUrl,
      _PayloadType.search => parser.searchQuery,
      _PayloadType.suggestion => parser.suggestionQuery,
    };

    if (loadQuery.isEmpty) {
      return _ScanResult.empty;
    }

    final test = loadQuery
        .replaceAll('{tags}', '*')
        .replaceAll('{tag-part}', 'a')
        .replaceAll('{post-limit}', '3')
        .replaceAll('{page-id}', '1')
        .replaceAll('{post-offset}', '3')
        .replaceAll('{post-id}', '100');
    try {
      final testUrl = '$host/$test';
      final res = await client.get(
        testUrl,
        options: Options(
          validateStatus: (it) => it == 200,
          headers: parser.headers,
          responseType: type == _PayloadType.post ? ResponseType.stream : null,
        ),
        cancelToken: _cancelToken,
      );

      final origin = res.redirects.isNotEmpty && res.realUri.hasAuthority
          ? res.realUri.origin
          : host;

      if (type == _PayloadType.post) {
        return _ScanResult(origin: origin, parser: parser);
      }

      final contentType = res.headers['content-type'] ?? [];
      final strData = res.data.toString();
      if (contentType.any((it) => it.contains(RegExp(r'(json|xml)'))) &&
          strData.isEmpty) {
        return _ScanResult.empty;
      }

      final isHTMLContent = contentType.any((it) => it.contains('html'));

      return _ScanResult(
        origin: origin,
        parser: isHTMLContent ? const NoParser() : parser,
      );
    } on DioException {
      return _ScanResult.empty;
    }
  }

  Future<(_PayloadType, _ScanResult)> _makeStubRequests(
      String host, _PayloadType type) async {
    final result = await Future.wait<_ScanResult>(
      parsers.map((x) => _tryQuery(host, x, type)),
    );

    result.sortBy((x) => x.parser.id.fileExt);
    final firstFound = result.firstWhere(
      (it) => it.parser is! NoParser,
      orElse: () => _ScanResult(origin: host),
    );
    return (type, firstFound);
  }

  void cancel() {
    _cancelToken.cancel();
    _cancelToken = CancelToken();
  }

  Future<ServerData> scan(String homeUrl, String apiUrl) async {
    final api = apiUrl.replaceFirst(RegExp(r'/$'), '');
    final home = homeUrl.replaceFirst(RegExp(r'/$'), '');

    final tests = await Future.wait([
      _makeStubRequests(api, _PayloadType.search),
      _makeStubRequests(api, _PayloadType.suggestion),
      _makeStubRequests(home, _PayloadType.post),
    ]);

    return tests.fold<ServerData>(
      ServerData(id: home.toUri().host),
      (prev, it) {
        final (type, res) = it;

        switch (type) {
          case _PayloadType.search:
            return prev.copyWith(
              searchParserId: res.parser.id,
              searchUrl: res.parser.searchQuery,
              apiAddr: res.origin,
            );
          case _PayloadType.suggestion:
            return prev.copyWith(
              suggestionParserId: res.parser.id,
              tagSuggestionUrl: res.parser.suggestionQuery,
              apiAddr: res.origin,
            );
          case _PayloadType.post:
            return prev.copyWith(
              postUrl: res.parser.postUrl,
              homepage: res.origin,
            );
        }
      },
    );
  }
}
