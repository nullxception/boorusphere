import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:dio/dio.dart';

abstract class BooruParser {
  const BooruParser();

  String get id;
  String get postUrl => '';
  String get suggestionQuery => '';
  String get searchQuery => '';
  Map<String, String> get headers => {};
  Iterable<BooruParserType> get type;
  bool canParsePage(Response res) => false;
  Iterable<Post> parsePage(Server server, Response res) => [];
  bool canParseSuggestion(Response res) => false;
  Iterable<String> parseSuggestion(Server server, Response res) => [];
}

enum BooruParserType { search, suggestion }

class NoParser extends BooruParser {
  const NoParser();

  @override
  final id = '';

  @override
  List<BooruParserType> get type => [];
}
