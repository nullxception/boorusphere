import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';

class DanbooruV113XmlParser extends BooruParser {
  @override
  final suggestionQuery =
      'tag/index.xml?name=*{tag-part}*&order=count&limit={post-limit}';

  @override
  final searchQuery =
      'post/index.xml?limit={post-limit}&page={page-id}&tags={tags}';
}
