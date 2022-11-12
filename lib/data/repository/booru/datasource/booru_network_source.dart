import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';

class BooruNetworkSource {
  BooruNetworkSource(this.client);
  final Dio client;

  Future<List<Response>> fetchSuggestion(ServerData server, String query) {
    final queries = query.toWordList();
    final word = queries.isEmpty ? '' : queries.last;
    final urls = server.suggestionUrlsOf(word);
    return Future.wait(urls.map(client.get));
  }

  Future<Response> fetchPage(String url) => client.get(url);
}
