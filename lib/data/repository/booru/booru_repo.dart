import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/booruonrailsjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmiexml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/szuruboorujson_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/imageboards_repo.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BooruRepo implements ImageboardRepo {
  BooruRepo({
    required this.client,
    required this.server,
    required this.serverDataState,
  });

  final Dio client;
  final _opt = Options(validateStatus: (it) => it == 200);
  final ServerDataState serverDataState;

  @override
  final ServerData server;

  List<BooruParser> get parsers => [
        DanbooruJsonParser(server),
        KonachanJsonParser(server),
        GelbooruXmlParser(server),
        GelbooruJsonParser(server),
        E621JsonParser(server),
        BooruOnRailsJsonParser(server),
        SafebooruXmlParser(server),
        ShimmieXmlParser(server),
        SzurubooruJsonParser(server),
      ];

  @override
  Future<Set<String>> getSuggestion(String word) async {
    var parser = parsers.firstWhere((x) => x.id == server.searchParserId,
        orElse: NoParser.new);

    final suggestionUrl = server.suggestionUrlsOf(word);

    final res = await client.get(suggestionUrl,
        options: _opt.copyWith(headers: parser.headers));

    if (parser is! NoParser) {
      debugPrint('getSuggestion: using ${parser.id}_parser');
      return parser.parseSuggestion(res).toSet();
    }

    parser = parsers.firstWhere((it) => it.canParseSuggestion(res),
        orElse: NoParser.new);

    if (parser.id.isNotEmpty) {
      debugPrint(
          'getSuggestion: parser resolved, now using ${parser.id}_parser');
      await serverDataState.edit(
          server, server.copyWith(suggestionParserId: parser.id));
    }

    return parser.parseSuggestion(res).toSet();
  }

  @override
  Future<Set<Post>> getPage(PageOption option, int index) async {
    var parser = parsers.firstWhere((x) => x.id == server.searchParserId,
        orElse: NoParser.new);

    final searchUrl = server.searchUrlOf(
        option.query, index, option.searchRating, option.limit);

    final res = await client.get(searchUrl,
        options: _opt.copyWith(headers: parser.headers));

    if (parser is! NoParser) {
      debugPrint('getPage: using ${parser.id}_parser');
      return parser.parsePage(res).toSet();
    }

    parser =
        parsers.firstWhere((it) => it.canParsePage(res), orElse: NoParser.new);

    if (parser.id.isNotEmpty) {
      debugPrint('getPage: parser resolved, now using ${parser.id}_parser');
      await serverDataState.edit(
          server, server.copyWith(searchParserId: parser.id));
    }

    return parser.parsePage(res).toSet();
  }
}
