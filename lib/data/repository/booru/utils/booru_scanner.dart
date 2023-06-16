import 'dart:async';

import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

BooruScanner useBooruScanner(
  Dio client,
  List<BooruParser> parsers, [
  List<Object?> keys = const [],
]) {
  final scanner = useMemoized(() {
    return BooruScanner(parsers: parsers, client: client);
  }, [client, parsers, ...keys]);

  useEffect(() {
    return scanner.stop;
  }, keys);

  return scanner;
}

enum _ScanType {
  search,
  suggestion,
  post,
}

class _ScanResult {
  const _ScanResult({
    this.origin = '',
    this.parserId = '',
    this.authBuilderId,
    this.query = '',
  });

  final String origin;
  final String parserId;
  final String query;
  final String? authBuilderId;

  static const empty = _ScanResult();
}

class BooruScanner {
  BooruScanner({required this.parsers, required this.client});

  final List<BooruParser> parsers;
  final Dio client;

  late CancelToken _cancelToken = CancelToken();

  final _logsHolder = <String>[];
  late StreamController<List<String>> _logs = StreamController.broadcast();

  Stream<List<String>> get logs => _logs.stream;

  _log([String msg = '']) {
    if (!_logs.isClosed) {
      _logsHolder.add(msg);
      _logs.add(_logsHolder);
    }
  }

  Future<_ScanResult> _scan(
    String host, {
    required BooruParser parser,
    required _ScanType type,
  }) async {
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
              origin: origin,
              parserId: parser.id,
              query: parser.searchQuery,
              authBuilderId: parser.id);
        }

        final realParser = parsers.firstWhere((x) => x.canParsePage(res),
            orElse: NoParser.new);
        return _ScanResult(
            origin: origin,
            parserId: realParser.id,
            query: parser.searchQuery,
            authBuilderId: parser.id);
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

  Stream<_ScanResult> _performScans(String host,
      {required _ScanType type}) async* {
    final results = <_ScanResult>[];
    final requests = parsers.mapIndexed((i, parser) async {
      if (i > 0) {
        await Future.delayed(Duration(milliseconds: i * 100));
      }
      return _scan(host, parser: parser, type: type);
    });

    await for (final result in Future.wait(requests).asStream()) {
      for (final scanResult in result) {
        if (scanResult != _ScanResult.empty) {
          results.add(scanResult);
        }

        yield _ScanResult.empty;
      }
    }

    results.sortBy((x) => x.parserId.fileExt);
    final firstFound = results.firstWhere(
      (it) => it.query.isNotEmpty && it.parserId.isNotEmpty,
      orElse: () =>
          _ScanResult(origin: host, authBuilderId: '', parserId: '', query: ''),
    );

    if (firstFound.parserId.isEmpty) {
      _log('❌ no ${type.name}Query matched');
    } else {
      _log('✔️ ${type.name}Query matched: ${firstFound.parserId}');
    }

    _log();
    yield firstFound;
  }

  Future<Server> scan(String homeUrl, String apiUrl) async {
    final api = apiUrl.replaceFirst(RegExp(r'/$'), '');
    final home = homeUrl.replaceFirst(RegExp(r'/$'), '');
    var data = Server.empty;

    _logsHolder.clear();
    _logs = StreamController.broadcast();

    _log('🧐 Scanning search query...');
    _cancelToken = CancelToken();
    final search = _performScans(api, type: _ScanType.search);
    await for (var ev in search) {
      if (ev == _ScanResult.empty) {
        continue;
      }

      data = data.copyWith(
        searchParserId: ev.parserId,
        searchUrl: ev.query,
        apiAddr: ev.origin,
      );
    }

    _log('🧐 Scanning suggestion query...');
    final suggestion = _performScans(api, type: _ScanType.suggestion);
    await for (var ev in suggestion) {
      if (ev == _ScanResult.empty) {
        continue;
      }

      data = data.copyWith(
        suggestionParserId: ev.parserId,
        tagSuggestionUrl: ev.query,
        apiAddr: ev.origin,
      );
    }

    _log('🧐 Scanning web post query...');
    final post = _performScans(home, type: _ScanType.post);
    await for (var ev in post) {
      if (ev == _ScanResult.empty) {
        continue;
      }

      data = data.copyWith(
        postUrl: ev.query,
        homepage: ev.origin,
      );
    }

    data = data.copyWith(
      apiAddr: data.apiAddr == data.homepage ? '' : data.apiAddr,
      id: home.toUri().host,
    );

    await stop();
    return data;
  }

  Future<void> stop() async {
    _cancelToken.cancel();
    _logsHolder.clear();
    await _logs.close();
  }
}