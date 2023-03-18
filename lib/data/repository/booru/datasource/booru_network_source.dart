import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:dio/dio.dart';

class BooruNetworkSource {
  BooruNetworkSource(this.client);

  final Dio client;
  final _opt = Options(validateStatus: (it) => it == 200);

  Future<Response> fetchSuggestion(ServerData server, String word) {
    final url = server.suggestionUrlsOf(word);
    return client.get(url, options: _opt);
  }

  Future<Response> fetchPage(String url) {
    return client.get(url, options: _opt);
  }
}
