import 'dart:async';

import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/booruonrailsjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmiexml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/szuruboorujson_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

enum _ScanType {
  search,
  suggestion,
  post,
}

class _ScanResult {
  const _ScanResult({
    this.origin = '',
    this.parserId = '',
    this.query = '',
  });

  final String origin;
  final String parserId;
  final String query;

  static const empty = _ScanResult();
}

class BooruScanner {
  BooruScanner(this.client);

  final Dio client;

  late CancelToken _cancelToken = CancelToken();

  final parsers = [
    BooruOnRailsJsonParser(ServerData.empty),
    DanbooruJsonParser(ServerData.empty),
    DanbooruV113JsonParser(),
    DanbooruV113XmlParser(),
    E621JsonParser(ServerData.empty),
    GelbooruJsonParser(ServerData.empty),
    GelbooruXmlParser(ServerData.empty),
    KonachanJsonParser(ServerData.empty),
    SafebooruXmlParser(ServerData.empty),
    ShimmieXmlParser(ServerData.empty),
    SzurubooruJsonParser(ServerData.empty),
  ];

  final _logsHolder = <String>[];
  StreamController<List<String>> _logs = StreamController();

  Stream<List<String>> get logs => _logs.stream;

  _log([String msg = '']) {
    if (!_logs.isClosed) {
      _logsHolder.add(msg);
      _logs.add(_logsHolder);
    }
  }

  Future<_ScanResult> _scan(
    String host,
    BooruParser parser,
    _ScanType type,
  ) async {
    final loadQuery = switch (type) {
      _ScanType.post => parser.postUrl,
      _ScanType.search => parser.searchQuery,
      _ScanType.suggestion => parser.suggestionQuery,
    };

    if (loadQuery.isEmpty || _cancelToken.isCancelled) {
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
      _log('→ checking ${type.name}::${parser.id}...');
      final res = await client.get(
        testUrl,
        options: Options(
          validateStatus: (it) => it == 200,
          headers: parser.headers,
          responseType: type == _ScanType.post ? ResponseType.stream : null,
        ),
        cancelToken: _cancelToken,
      );

      final origin = res.redirects.isNotEmpty && res.realUri.hasAuthority
          ? res.realUri.origin
          : host;

      if (type == _ScanType.post) {
        return _ScanResult(
            origin: origin, parserId: parser.id, query: parser.postUrl);
      }

      if (type == _ScanType.search) {
        if (parser.canParsePage(res)) {
          return _ScanResult(
              origin: origin, parserId: parser.id, query: parser.searchQuery);
        }

        final realParser = parsers.firstWhere((x) => x.canParsePage(res),
            orElse: NoParser.new);
        return _ScanResult(
            origin: origin, parserId: realParser.id, query: parser.searchQuery);
      }

      if (type == _ScanType.suggestion) {
        if (parser.canParseSuggestion(res)) {
          return _ScanResult(
              origin: origin,
              parserId: parser.id,
              query: parser.suggestionQuery);
        }

        final realParser = parsers.firstWhere((x) => x.canParseSuggestion(res),
            orElse: NoParser.new);
        return _ScanResult(
            origin: origin,
            parserId: realParser.id,
            query: parser.suggestionQuery);
      }

      return _ScanResult.empty;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }

      return _ScanResult.empty;
    }
  }

  Stream<_ScanResult> _performScans(String host, _ScanType type) async* {
    final results = <_ScanResult>[];
    final requests = parsers.mapIndexed((i, parser) async {
      if (i > 0) {
        await Future.delayed(Duration(milliseconds: i * 100));
      }
      return _scan(host, parser, type);
    });

    await for (final result in Future.wait(requests).asStream()) {
      for (final scanResult in result) {
        if (scanResult != _ScanResult.empty) {
          results.add(scanResult);
        }

        if (_logs.isClosed) return;
        yield _ScanResult.empty;
      }
    }

    results.sortBy((x) => x.parserId.fileExt);
    final firstFound = results.firstWhere(
      (it) => it.query.isNotEmpty && it.parserId.isNotEmpty,
      orElse: () => _ScanResult(origin: host),
    );

    if (firstFound.parserId.isEmpty) {
      _log('❌ no ${type.name}Query matched');
    } else {
      _log('✔️ ${type.name}Query matched: ${firstFound.parserId}');
    }

    _log();
    if (_logs.isClosed) return;
    yield firstFound;
  }

  Stream<ServerData> scan(String homeUrl, String apiUrl) async* {
    final api = apiUrl.replaceFirst(RegExp(r'/$'), '');
    final home = homeUrl.replaceFirst(RegExp(r'/$'), '');
    var data = ServerData.empty;
    _logsHolder.clear();
    if (_logs.isClosed) {
      _logs = StreamController();
    }

    _log('🧐 Scanning search query...');
    _cancelToken = CancelToken();
    final search = _performScans(api, _ScanType.search);
    await for (var ev in search) {
      if (ev == _ScanResult.empty) {
        if (_logs.isClosed) return;
        yield data;
        continue;
      }
      data = data.copyWith(
        searchParserId: ev.parserId,
        searchUrl: ev.query,
        apiAddr: ev.origin,
      );
      if (_logs.isClosed) return;
      yield data;
    }

    _log('🧐 Scanning suggestion query...');
    final suggestion = _performScans(api, _ScanType.suggestion);
    await for (var ev in suggestion) {
      if (ev == _ScanResult.empty) {
        if (_logs.isClosed) return;
        yield data;
        continue;
      }

      data = data.copyWith(
        suggestionParserId: ev.parserId,
        tagSuggestionUrl: ev.query,
        apiAddr: ev.origin,
      );
      if (_logs.isClosed) return;
      yield data;
    }

    _log('🧐 Scanning web post query...');
    final post = _performScans(home, _ScanType.post);
    await for (var ev in post) {
      if (ev == _ScanResult.empty) {
        yield data;
        continue;
      }

      data = data.copyWith(
        postUrl: ev.query,
        homepage: ev.origin,
      );
      if (_logs.isClosed) return;
      yield data;
    }

    data = data.copyWith(
      apiAddr: data.apiAddr == data.homepage ? '' : data.apiAddr,
      id: home.toUri().host,
    );
    if (_logs.isClosed) return;
    yield data;
    await stop();
  }

  Future<void> stop() async {
    _cancelToken.cancel();
    await _logs.close();
  }
}
