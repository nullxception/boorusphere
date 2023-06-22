import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';

class DanbooruV113XmlParser extends BooruParser {
  @override
  final id = 'Danbooru-v1.13.xml';

  @override
  final searchQuery =
      'post/index.xml?limit={post-limit}&page={page-id}&tags={tags}';

  @override
  final suggestionQuery =
      'tag/index.xml?name=*{tag-part}*&order=count&limit={post-limit}';

  @override
  List<BooruParserType> get type => [];
}
