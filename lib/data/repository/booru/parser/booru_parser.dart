import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';


abstract class BooruParser  {
  ServerData get server => ServerData.empty;
  bool canParsePage(Response res) => false;
  Iterable<Post> parsePage(Response res) => [];
  bool canParseSuggestion(Response res) => false;
  Iterable<String> parseSuggestion(Response res) => [];
}

class NoParser extends BooruParser {}
