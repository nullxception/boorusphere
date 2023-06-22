import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/domain/repository/imageboards_repo.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class BooruRepo implements ImageboardRepo {
  BooruRepo({
    required this.parsers,
    required this.client,
    required this.server,
    required this.serverState,
  });

  final Iterable<BooruParser> parsers;
  final Dio client;
  final ServerState serverState;

  final _opt = Options(validateStatus: (it) => it == 200);
  final _log = Logger('BooruRepo');

  @override
  final Server server;

  Future<Response> _request(String url, BooruParser parser) {
    return client.get(url, options: _opt.copyWith(headers: parser.headers));
  }

  @override
  Future<Set<String>> getSuggestion(String word) async {
    var parser = parsers.firstWhere((x) => x.id == server.suggestionParserId,
        orElse: NoParser.new);

    final suggestionUrl = server.suggestionUrlsOf(word);
    final res = await _request(suggestionUrl, parser);

    if (parser.canParseSuggestion(res)) {
      _log.i('getSuggestion(${server.name}): using ${parser.id}_parser');
      return parser.parseSuggestion(server, res).toSet();
    }

    parser = parsers.firstWhere((it) => it.canParseSuggestion(res),
        orElse: NoParser.new);

    if (parser.id.isNotEmpty) {
      _log.i(
          'getSuggestion(${server.name}): parser resolved, now using ${parser.id}_parser');
      await serverState.edit(
          server, server.copyWith(suggestionParserId: parser.id));
    }

    return parser.parseSuggestion(server, res).toSet();
  }

  @override
  Future<Set<Post>> getPage(PageOption option, int index) async {
    var parser = parsers.firstWhere((x) => x.id == server.searchParserId,
        orElse: NoParser.new);

    final searchUrl = server.searchUrlOf(option, page: index);
    final res = await _request(searchUrl, parser);

    if (parser.canParsePage(res)) {
      _log.i('getPage(${server.name}): using ${parser.id}_parser');
      return parser.parsePage(server, res).toSet();
    }

    parser =
        parsers.firstWhere((it) => it.canParsePage(res), orElse: NoParser.new);

    if (parser.id.isNotEmpty) {
      _log.i(
          'getPage(${server.name}): parser resolved, now using ${parser.id}_parser');
      await serverState.edit(
          server, server.copyWith(searchParserId: parser.id));
    }

    return parser.parsePage(server, res).toSet();
  }
}
