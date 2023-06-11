import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';

class DanbooruV113JsonParser extends BooruParser {
  @override
  final suggestionQuery =
      'tag/index.json?name=*{tag-part}*&order=count&limit={post-limit}';

  @override
  final searchQuery =
      'post/index.json?limit={post-limit}&page={page-id}&tags={tags}';
}
