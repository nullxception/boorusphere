import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';

class NoParser extends BooruParser {
  NoParser() : super(const ServerData());

  @override
  bool canParsePage(Response res) {
    return false;
  }

  @override
  List<Post> parsePage(res) {
    return [];
  }

  @override
  bool canParseSuggestion(Response res) {
    return false;
  }

  @override
  Set<String> parseSuggestion(Response res) {
    return {};
  }
}
