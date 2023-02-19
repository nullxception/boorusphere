import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/booru_result.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmiexml_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:collection/collection.dart';

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
        SafebooruXmlParser(server),
        ShimmieXmlParser(server),
      ];

  @override
  Future<BooruResult<List<String>>> getSuggestion(String query) async {
    final queries = query.toWordList();
    final word = queries.isEmpty || query.endsWith(' ') ? '' : queries.last;
    final res = await networkSource.fetchSuggestion(server, word);
    try {
      final data = res
          .map((resp) {
            if (resp.statusCode != 200) {
              throw BooruError.httpError;
            }

            try {
              return parser
                  .firstWhere((it) => it.canParseSuggestion(resp))
                  .parseSuggestion(resp);
            } on StateError {
              throw BooruError.empty;
            }
          })
          .reduce((value, element) => {...value, ...element})
          .sortedByCompare<String>(
            (element) => element,
            (a, b) {
              if (a.startsWith(word)) return -1;
              if (a.endsWith(word)) return 0;
              return 1;
            },
          );

      return BooruResult.data(data);
    } catch (e, s) {
      if (query.isEmpty) {
        // the server did not support empty tag matches (hot/trending tags)
        return const BooruResult.data([]);
      } else if (e == BooruError.httpError) {
        return BooruResult.error(
            res.firstWhere(
              (element) => element.statusCode != 200,
              orElse: () => res.first,
            ),
            error: e,
            stackTrace: s);
      } else {
        return BooruResult.error(res.last, error: e, stackTrace: s);
      }
    }
  }

  @override
  Future<BooruResult<List<Post>>> getPage(
    PageOption option,
    int index,
  ) async {
    final url = server.searchUrlOf(
      option.query,
      index,
      option.searchRating,
      option.limit,
    );
    final res = await networkSource.fetchPage(url);
    if (res.statusCode != 200) {
      return BooruResult.error(res, error: BooruError.httpError);
    }

    try {
      return BooruResult.data(
        parser.firstWhere(
          (it) => it.canParsePage(res),
          orElse: () {
            throw BooruError.empty;
          },
        ).parsePage(res),
        src: url,
      );
    } on BooruError catch (e) {
      return BooruResult.error(res, error: e);
    }
  }
}
