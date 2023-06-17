import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/booruonrails_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/e621_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooru_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/moebooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/safebooru_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/shimmie_xml_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/szurubooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/provider.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_scanner.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../presentation/state/app_version_test.dart';
import '../../utils/dio.dart';
import '../../utils/mocktail.dart';
import '../../utils/riverpod.dart';

void main() async {
  setupLogger(test: true);
  setupMocktailFallbacks();
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer ref = ProviderContainer(overrides: [
    envRepoProvider.overrideWithValue(FakeEnvRepo()),
  ]);
  late DioAdapterMock adapter =
      DioAdapterMock(ref.read(dioProvider), byIntercepting: true);
  late List<BooruParser> parsers = ref.read(booruParsersProvider);

  group('Scanner', () {
    setUpAll(() async {
      ref.setupTestFor(dioProvider);
      ref.setupTestFor(booruParsersProvider);
    });

    tearDownAll(ref.dispose);

    test('Danbooru', () async {
      const host = 'https://danbooru.test';
      adapter
        ..put(
          '$host/posts.json?tags=*&page=1&limit=3',
          FakeResponseBody.fromFixture('danbooru/posts.json', 200),
        )
        ..put(
          '$host/tags.json?search[name_matches]=*a*&search[order]=count&limit=3',
          FakeResponseBody.fromFixture('danbooru/tags.json', 200),
        )
        ..put(
          '$host/posts/100',
          FakeResponseBody.fromFixture('danbooru/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = DanbooruJsonParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, parser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, parser.id);
      expect(result.postUrl, parser.postUrl);
    });

    test('Gelbooru', () async {
      const host = 'https://gelbooru.test';

      adapter
        ..put(
          '$host/index.php?page=dapi&s=post&q=index&tags=*&pid=1&limit=3&json=1',
          FakeResponseBody.fromFixture('gelbooru/posts.json', 200),
        )
        ..put(
          '$host/index.php?page=dapi&s=tag&q=index&name_pattern=%25a%25&orderby=count&limit=3&json=1',
          FakeResponseBody.fromFixture('gelbooru/tags.json', 200),
        )
        ..put(
          '$host/index.php?page=post&s=view&id=100',
          FakeResponseBody.fromFixture('gelbooru/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parserJson = GelbooruJsonParser();
      final parserXml = GelbooruXmlParser();

      expect(result.searchUrl, parserJson.searchQuery);
      expect(result.searchParserId, parserJson.id);
      expect(result.tagSuggestionUrl, parserJson.suggestionQuery);
      expect(result.suggestionParserId, parserJson.id);
      expect(result.postUrl, parserXml.postUrl);
    });

    test('Moebooru', () async {
      const host = 'https://konachan.test';

      adapter
        ..put(
          '$host/post.json?tags=*&page=1&limit=3',
          FakeResponseBody.fromFixture('konachan/posts.json', 200),
        )
        ..put(
          '$host/tag.json?name=*a*&order=count&limit=3',
          FakeResponseBody.fromFixture('konachan/tags.json', 200),
        )
        ..put(
          '$host/post/show/100',
          FakeResponseBody.fromFixture('konachan/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = MoebooruJsonParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, parser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, parser.id);
      expect(result.postUrl, parser.postUrl);
    });

    test('Safebooru', () async {
      const host = 'https://safebooru.test';
      adapter
        ..put(
          '$host/index.php?page=dapi&s=post&q=index&tags=*&pid=1&limit=3',
          FakeResponseBody.fromFixture('safebooru/posts.xml', 200),
        )
        ..put(
          '$host/index.php?page=dapi&s=tag&q=index&name_pattern=%25a%25&orderby=count&limit=3',
          FakeResponseBody.fromFixture('safebooru/tags.xml', 200),
        )
        ..put(
          '$host/index.php?page=post&s=view&id=100',
          FakeResponseBody.fromFixture('safebooru/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = GelbooruXmlParser();
      final resultParser = SafebooruXmlParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, resultParser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, resultParser.id);
      expect(result.postUrl, parser.postUrl);
    });

    test('BooruOnRails', () async {
      const host = 'https://derpibooru.test';
      adapter
        ..put(
          '$host/api/v1/json/search/images?q=*&per_page=3&page=1',
          FakeResponseBody.fromFixture('booruonrails/posts.json', 200),
        )
        ..put(
          '$host/api/v1/json/search/tags?q=a*',
          FakeResponseBody.fromFixture('booruonrails/tags.json', 200),
        )
        ..put(
          '$host/100',
          FakeResponseBody.fromFixture('booruonrails/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = BooruOnRailsJsonParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, parser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, parser.id);
      expect(result.postUrl, parser.postUrl);
    });

    test('E621', () async {
      const host = 'https://e621.test';
      adapter
        ..put(
          '$host/posts.json?tags=*&page=1&limit=3',
          FakeResponseBody.fromFixture('e621/posts.json', 200),
        )
        ..put(
          '$host/tags.json?search[name_matches]=*a*&search[order]=count&limit=3',
          FakeResponseBody.fromFixture('e621/tags.json', 200),
        )
        ..put(
          '$host/posts/100',
          FakeResponseBody.fromFixture('e621/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = DanbooruJsonParser();
      final pageParser = E621JsonParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, pageParser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, parser.id);
      expect(result.postUrl, parser.postUrl);
    });

    test('Shimmie', () async {
      const host = 'https://rule34.paheal.test';
      adapter
        ..put(
          '$host/api/danbooru/find_posts/index.xml?tags=*&limit=3&page=1',
          FakeResponseBody.fromFixture('rule34.paheal/posts.xml', 200),
        )
        ..put(
          '$host/api/internal/autocomplete?s=a',
          FakeResponseBody.fromFixture('rule34.paheal/tags.json', 200),
        )
        ..put(
          '$host/post/view/100',
          FakeResponseBody.fromFixture('rule34.paheal/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = ShimmieXmlParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, parser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, parser.id);
      expect(result.postUrl, parser.postUrl);
    });

    test('Szurubooru', () async {
      const host = 'https://homestuck.test/resources/booru';
      adapter
        ..put(
          '$host/api/posts/?offset=3&limit=3&query=*',
          FakeResponseBody.fromFixture('szurubooru/posts.json', 200),
        )
        ..put(
          '$host/api/tags/?offset=0&limit=3&query=a*',
          FakeResponseBody.fromFixture('szurubooru/tags.json', 200),
        )
        ..put(
          '$host/post/100',
          FakeResponseBody.fromFixture('szurubooru/post.html', 200),
        );

      final scanner =
          BooruScanner(parsers: parsers, client: ref.read(dioProvider));

      final result = await scanner.scan(host, host);
      final parser = SzurubooruJsonParser();

      expect(result.searchUrl, parser.searchQuery);
      expect(result.searchParserId, parser.id);
      expect(result.tagSuggestionUrl, parser.suggestionQuery);
      expect(result.suggestionParserId, parser.id);
      expect(result.postUrl, parser.postUrl);
    });
  });
}
