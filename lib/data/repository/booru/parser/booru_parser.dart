import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';

abstract class BooruParser {
  const BooruParser();

  String get id;
  String get postUrl => '';
  String get suggestionQuery => '';
  String get searchQuery => '';
  Map<String, String> get headers => {};
  bool canParsePage(Response res) => false;
  Iterable<Post> parsePage(ServerData server, Response res) => [];
  bool canParseSuggestion(Response res) => false;
  Iterable<String> parseSuggestion(ServerData server, Response res) => [];
}

class NoParser extends BooruParser {
  const NoParser();

  @override
  final id = '';
}
