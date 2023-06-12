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

class _ScanResult {
  const _ScanResult({
    this.origin = '',
    this.payloadData = ('', ''),
    this.hasFileUrl = false,
  });

  final String origin;
  final (String, String) payloadData;
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
    (String, String) payloadData,
    _PayloadType type,
  ) async {
    final (loadName, loadQuery) = payloadData;
    final test = loadQuery
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
        return _ScanResult(origin: origin, payloadData: payloadData);
      }

      final contentType = res.headers['content-type'] ?? [];
      final strData = res.data.toString();
      if (contentType.any((it) => it.contains(RegExp(r'(json|xml)'))) &&
          strData.isEmpty) {
        return _ScanResult.empty;
      }

      final fileUrlRegExp = RegExp("https?://.*/.+\\.[a-zA-Z]{2,4}[\"']");
      final query =
          contentType.any((it) => it.contains('html')) ? '' : loadQuery;

      return _ScanResult(
        origin: origin,
        payloadData: (loadName, query),
        hasFileUrl: strData.contains(fileUrlRegExp),
      );
    } on DioException {
      return _ScanResult.empty;
    }
  }

  Future<(_PayloadType, _ScanResult)> _makeStubRequests(
      String host, _PayloadType type) async {
    final queries = parsers.map(
      (e) => switch (type) {
        _PayloadType.post => (e.id, e.postUrl),
        _PayloadType.search => (e.id, e.searchQuery),
        _PayloadType.suggestion => (e.id, e.suggestionQuery),
      },
    );
    final result = await Future.wait<_ScanResult>(
      queries.map((x) => _tryQuery(host, x, type)),
    );

    final firstFound = result.firstWhere(
      (it) => it.payloadData.$2.isNotEmpty,
      orElse: () => _ScanResult(origin: host),
    );

    return (
      type,
      type == _PayloadType.search
          ? result.firstWhere((it) => it.hasFileUrl, orElse: () => firstFound)
          : firstFound,
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
        final (type, res) = it;
        final (payloadType, payloadUrl) = res.payloadData;

        switch (type) {
          case _PayloadType.search:
            return prev.copyWith(
              searchParserId: payloadType,
              searchUrl: payloadUrl,
              apiAddr: res.origin,
            );
          case _PayloadType.suggestion:
            return prev.copyWith(
              suggestionParserId: payloadType,
              tagSuggestionUrl: payloadUrl,
              apiAddr: res.origin,
            );
          case _PayloadType.post:
            return prev.copyWith(
              postUrl: payloadUrl,
              homepage: res.origin,
            );
        }
      },
    );
  }
}
