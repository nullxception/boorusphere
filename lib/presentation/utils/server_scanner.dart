import 'dart:async';

import 'package:boorusphere/data/repository/booru/parser/booruonrailsjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmiexml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/szuruboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_util.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';

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
    this.hasFileUrl = false,
  });

  final String origin;
  final String query;
  final bool hasFileUrl;

  static const empty = _ScanResult();
}

class ServerScanner {
  ServerScanner(this.client);

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
    String query,
    _PayloadType type,
  ) async {
    final test = query
        .replaceAll('{tags}', '*')
        .replaceAll('{tag-part}', 'a')
        .replaceAll('{post-limit}', '3')
        .replaceAll('{page-id}', '1')
        .replaceAll('{post-offset}', '3')
        .replaceAll('{post-id}', '100');
    try {
      final testUrl = '$host/$test';
      final (url, headers) = BooruUtil.constructHeaders(testUrl);
      final res = await client.get(
        url,
        options: Options(
          validateStatus: (it) => it == 200,
          headers: headers,
          responseType: type == _PayloadType.post ? ResponseType.stream : null,
        ),
        cancelToken: _cancelToken,
      );

      final origin = res.redirects.isNotEmpty && res.realUri.hasAuthority
          ? res.realUri.origin
          : host;

      if (type == _PayloadType.post) {
        return _ScanResult(origin: origin, query: query);
      }

      final contentType = res.headers['content-type'] ?? [];
      final strData = res.data.toString();
      if (contentType.any((it) => it.contains(RegExp(r'(json|xml)'))) &&
          strData.isEmpty) {
        return _ScanResult.empty;
      }

      final fileUrlRegExp = RegExp("https?://.*/.+\\.[a-zA-Z]{2,4}[\"']");
      return _ScanResult(
        origin: origin,
        query: contentType.any((it) => it.contains('html')) ? '' : query,
        hasFileUrl: strData.contains(fileUrlRegExp),
      );
    } on DioException {
      return _ScanResult.empty;
    }
  }

  Future<_Payload> _makeStubRequests(String host, _PayloadType type) async {
    final queries = parsers.map(
      (e) => switch (type) {
        _PayloadType.post => e.postUrl,
        _PayloadType.search => e.searchQuery,
        _PayloadType.suggestion => e.suggestionQuery,
      },
    );
    final result = await Future.wait<_ScanResult>(
      queries.map((q) => _tryQuery(host, q, type)),
    );

    final firstFound = result.firstWhere(
      (it) => it.query.isNotEmpty,
      orElse: () => _ScanResult(origin: host),
    );

    return _Payload(
      result: type == _PayloadType.search
          ? result.firstWhere((it) => it.hasFileUrl, orElse: () => firstFound)
          : firstFound,
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
      _makeStubRequests(api, _PayloadType.search),
      _makeStubRequests(api, _PayloadType.suggestion),
      _makeStubRequests(home, _PayloadType.post),
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
}
