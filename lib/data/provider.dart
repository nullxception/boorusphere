import 'package:boorusphere/data/dio/app_dio.dart';
import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_local_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_network_source.dart';
import 'package:boorusphere/data/repository/download/datasource/downloader_source.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
CookieJar cookieJar(CookieJarRef ref) {
  return CookieJar();
}

@riverpod
VersionNetworkSource versionNetworkSource(VersionNetworkSourceRef ref) {
  final dio = ref.watch(dioProvider);
  return VersionNetworkSource(dio);
}

@riverpod
SettingLocalSource settingLocalSource(SettingLocalSourceRef ref) {
  final box = Hive.box(SettingLocalSource.key);
  return SettingLocalSource(box);
}

@riverpod
ServerLocalSource serverLocalSource(ServerLocalSourceRef ref) {
  final box = Hive.box<ServerData>(ServerLocalSource.key);
  return ServerLocalSource(assetBundle: rootBundle, box: box);
}

@riverpod
SearchHistoryLocalSource searchHistoryLocalSource(
    SearchHistoryLocalSourceRef ref) {
  final box = Hive.box<SearchHistory>(SearchHistoryLocalSource.key);
  return SearchHistoryLocalSource(box);
}

@riverpod
FavoritePostLocalSource favoritePostLocalSource(
    FavoritePostLocalSourceRef ref) {
  final box = Hive.box<FavoritePost>(FavoritePostLocalSource.key);
  return FavoritePostLocalSource(box);
}

@riverpod
ChangelogNetworkSource changelogNetworkSource(ChangelogNetworkSourceRef ref) {
  final dio = ref.watch(dioProvider);
  return ChangelogNetworkSource(dio);
}

@riverpod
ChangelogLocalSource changelogLocalSource(ChangelogLocalSourceRef ref) {
  return ChangelogLocalSource(rootBundle);
}

@riverpod
BooruNetworkSource booruNetworkSource(BooruNetworkSourceRef ref) {
  final dio = ref.watch(dioProvider);
  return BooruNetworkSource(dio);
}

@riverpod
BlockedTagsLocalSource blockedTagsLocalSource(BlockedTagsLocalSourceRef ref) {
  final box = Hive.box<String>(BlockedTagsLocalSource.key);
  return BlockedTagsLocalSource(box);
}

@riverpod
DownloaderSource downloaderSource(DownloaderSourceRef ref) {
  final box = Hive.box<DownloadEntry>(DownloaderSource.key);
  return DownloaderSource(box);
}

@riverpod
Dio dio(DioRef ref) {
  final cookieJar = ref.watch(cookieJarProvider);
  final envRepo = ref.watch(envRepoProvider);
  return AppDio(cookieJar: cookieJar, envRepo: envRepo);
}
