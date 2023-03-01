import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';

class BooruNetworkSource {
  BooruNetworkSource(this.client);
  final Dio client;

  Future<Response> fetchSuggestion(ServerData server, String word) {
    final url = server.suggestionUrlsOf(word);
    return client.get(url);
  }

  Future<Response> fetchPage(String url) => client.get(url);
}
