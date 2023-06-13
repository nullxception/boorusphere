import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/booruonrails_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooruv113_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooru_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/moebooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooru_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmie_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/szurubooru_json_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
List<BooruParser> booruParsers(BooruParsersRef ref) {
  return <BooruParser>[
    BooruOnRailsJsonParser(),
    DanbooruJsonParser(),
    DanbooruV113JsonParser(),
    DanbooruV113XmlParser(),
    E621JsonParser(),
    GelbooruJsonParser(),
    GelbooruXmlParser(),
    MoebooruJsonParser(),
    SafebooruXmlParser(),
    ShimmieXmlParser(),
    SzurubooruJsonParser(),
  ];
}
