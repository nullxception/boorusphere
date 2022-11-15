import 'package:boorusphere/data/repository/booru/entity/booru_result.dart';
import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';

abstract class BooruRepo {
  ServerData get server;
  Future<BooruResult<List<String>>> getSuggestion(String query);
  Future<BooruResult<List<Post>>> getPage(PageOption option, int index);
}
