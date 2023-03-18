import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/booruonrailsjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/no_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmiexml_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';

class BooruRepoImpl implements BooruRepo {
  BooruRepoImpl({required this.networkSource, required this.server});

  @override
  final ServerData server;

  final BooruNetworkSource networkSource;

  List<BooruParser> get parser => [
        DanbooruJsonParser(server),
        KonachanJsonParser(server),
        GelbooruXmlParser(server),
        GelbooruJsonParser(server),
        E621JsonParser(server),
        BooruOnRailsJsonParser(server),
        SafebooruXmlParser(server),
        ShimmieXmlParser(server),
      ];

  @override
  Future<Set<String>> getSuggestion(String word) async {
    final res = await networkSource.fetchSuggestion(server, word);
    final data = parser
        .firstWhere((it) => it.canParseSuggestion(res), orElse: NoParser.new)
        .parseSuggestion(res);

    return data.toSet();
  }

  @override
  Future<Set<Post>> getPage(PageOption option, int index) async {
    final url = server.searchUrlOf(
        option.query, index, option.searchRating, option.limit);
    final res = await networkSource.fetchPage(url);
    final data = parser
        .firstWhere((it) => it.canParsePage(res), orElse: NoParser.new)
        .parsePage(res);

    return data.toSet();
  }
}
