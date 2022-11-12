import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/page_response.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';

abstract class BooruRepo {
  ServerData get server;
  Future<Iterable<String>> getSuggestion(String query);
  Future<PageResponse> getPage(PageOption option, int index);
}
