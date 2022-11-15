import 'package:boorusphere/data/entity/sphere_exception.dart';
import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/booru/entity/booru_result.dart';
import 'package:boorusphere/data/repository/booru/entity/page_error.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelboorujson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooruxml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/konachanjson_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooruxml_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

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
      ];

  Set<String> _parseSuggestion(Response res, String query) {
    if (res.statusCode != 200) {
      throw SphereException(
          message: 'Cannot fetch data (HTTP ${res.statusCode})');
    }

    try {
      return parser
          .firstWhere((it) => it.canParseSuggestion(res))
          .parseSuggestion(res);
    } on StateError {
      throw SphereException(message: 'No tags that matches \'$query\'');
    }
  }

  @override
  Future<Iterable<String>> getSuggestion(
    String query,
  ) async {
    final queries = query.toWordList();
    final word = queries.isEmpty ? '' : queries.last;
    try {
      final res = await networkSource.fetchSuggestion(server, query);
      return res
          .map((e) => _parseSuggestion(e, query))
          .reduce((value, element) => {...value, ...element})
          .sortedByCompare<String>(
        (element) => element,
        (a, b) {
          if (a.startsWith(word)) return -1;
          if (a.endsWith(word)) return 0;
          return 1;
        },
      );
    } catch (e) {
      if (query.isEmpty) {
        // the server did not support empty tag matches (hot/trending tags)
        return [];
      }
      rethrow;
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
      option.safeMode,
      option.limit,
    );
    final res = await networkSource.fetchPage(url);
    if (res.statusCode != 200) {
      return BooruResult.error(res, PageError.httpError);
    } else if (!res.data.toString().contains(RegExp('https?'))) {
      // no url founds in the document means no image(s) available to display
      return BooruResult.data(url, []);
    }

    try {
      return BooruResult.data(
        url,
        parser.firstWhere((it) => it.canParsePage(res)).parsePage(res),
      );
    } on StateError {
      return BooruResult.error(res, PageError.noParser);
    }
  }
}
