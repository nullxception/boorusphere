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
import 'package:boorusphere/data/repository/booru/utils/booru_util.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/imageboards_repo.dart';
import 'package:dio/dio.dart';

class BooruRepo implements ImageboardRepo {
  BooruRepo({required this.client, required this.server});

  final Dio client;
  final _opt = Options(validateStatus: (it) => it == 200);

  @override
  final ServerData server;

  List<BooruParser> get parser => [
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
    final suggestionUrl = server.suggestionUrlsOf(word);

    final (url, headers) = BooruUtil.constructHeaders(suggestionUrl);
    final res = await client.get(url, options: _opt.copyWith(headers: headers));
    final data = parser
        .firstWhere((it) => it.canParseSuggestion(res), orElse: NoParser.new)
        .parseSuggestion(res);

    return data.toSet();
  }

  @override
  Future<Set<Post>> getPage(PageOption option, int index) async {
    final searchUrl = server.searchUrlOf(
        option.query, index, option.searchRating, option.limit);
    final (url, headers) = BooruUtil.constructHeaders(searchUrl);
    final res = await client.get(url, options: _opt.copyWith(headers: headers));
    final data = parser
        .firstWhere((it) => it.canParsePage(res), orElse: NoParser.new)
        .parsePage(res);

    return data.toSet();
  }
}
