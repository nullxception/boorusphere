import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/danbooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooru_json_parser.dart';
import 'package:boorusphere/data/repository/booru/parser/gelbooru_xml_parser.dart';
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
          FakeResponseBody.fromFakeData('danbooru/posts.json', 200),
        )
        ..put(
          '$host/tags.json?search[name_matches]=*a*&search[order]=count&limit=3',
          FakeResponseBody.fromFakeData('danbooru/tags.json', 200),
        )
        ..put(
          '$host/posts/100',
          FakeResponseBody.fromFakeData('danbooru/post.html', 200),
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
          FakeResponseBody.fromFakeData('gelbooru/posts.json', 200),
        )
        ..put(
          '$host/index.php?page=dapi&s=tag&q=index&name_pattern=%25a%25&orderby=count&limit=3&json=1',
          FakeResponseBody.fromFakeData('gelbooru/tags.json', 200),
        )
        ..put(
          '$host/index.php?page=post&s=view&id=100',
          FakeResponseBody.fromFakeData('gelbooru/post.html', 200),
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
  });
}
