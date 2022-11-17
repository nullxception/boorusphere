import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_local_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_network_source.dart';
import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/data/repository/version/datasource/version_local_source.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/utils/dio/headers_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final cookieJarProvider = Provider((ref) {
  return CookieJar();
});

final dioProvider = Provider((ref) {
  final dio = Dio();
  final cookieJar = ref.watch(cookieJarProvider);
  final retryDelays = List.generate(5, (index) {
    return Duration(milliseconds: 400 + (100 * (index + 1)));
  });

  dio.interceptors
    ..add(CookieManager(cookieJar))
    ..add(HeadersInterceptor())
    ..add(RetryInterceptor(
      dio: dio,
      retries: retryDelays.length,
      retryDelays: retryDelays,
    ));

  return dio;
});

final versionNetworkSourceProvider = Provider.autoDispose((ref) {
  final dio = ref.watch(dioProvider);
  return VersionNetworkSource(dio);
});

final versionLocalSourceProvider = Provider.autoDispose((ref) {
  return VersionLocalSource();
});

final settingsLocalSourceProvider = Provider.autoDispose((ref) {
  final box = Hive.box(SettingLocalSource.key);
  return SettingLocalSource(box);
});

final serverLocalSourceProvider = Provider.autoDispose((ref) {
  final box = Hive.box<ServerData>(ServerLocalSource.key);
  return ServerLocalSource(assetBundle: rootBundle, box: box);
});

final searchHistoryLocalSourceProvider = Provider.autoDispose((ref) {
  final box = Hive.box<SearchHistory>(SearchHistoryLocalSource.key);
  return SearchHistoryLocalSource(box);
});

final favoritePostLocalSourceProvider = Provider.autoDispose((ref) {
  final box = Hive.box<FavoritePost>(FavoritePostLocalSource.key);
  return FavoritePostLocalSource(box);
});

final changelogNetworkSourceProvider = Provider.autoDispose((ref) {
  final dio = ref.watch(dioProvider);
  return ChangelogNetworkSource(dio);
});

final changelogLocalSourceProvider = Provider.autoDispose((ref) {
  return ChangelogLocalSource(rootBundle);
});

final booruNetworkSourceProvider = Provider.autoDispose((ref) {
  final dio = ref.watch(dioProvider);
  return BooruNetworkSource(dio);
});

final blockedTagsLocalSourceProvider = Provider.autoDispose((ref) {
  final box = Hive.box<String>(BlockedTagsLocalSource.key);
  return BlockedTagsLocalSource(box);
});
