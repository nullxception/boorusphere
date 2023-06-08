import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/app_state/app_state_repo_impl.dart';
import 'package:boorusphere/data/repository/blocked_tags/blocked_tags_repo_impl.dart';
import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/data/repository/booru/booru_repo_impl.dart';
import 'package:boorusphere/data/repository/changelog/changelog_repo_impl.dart';
import 'package:boorusphere/data/repository/download/download_repo_impl.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/env/env_repo_impl.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/favorite_post/favorite_post_repo_impl.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/search_history/search_history_repo_impl.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/server/server_repo_impl.dart';
import 'package:boorusphere/data/repository/setting/setting_repo_impl.dart';
import 'package:boorusphere/data/repository/version/version_repo_impl.dart';
import 'package:boorusphere/domain/repository/app_state_repo.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:boorusphere/domain/repository/download_repo.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';
import 'package:boorusphere/domain/repository/server_repo.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:package_info/package_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
EnvRepo envRepo(EnvRepoRef ref) {
  throw UnimplementedError('must be initialized manually');
}

Future<EnvRepo> provideEnvRepo() async {
  return EnvRepoImpl(
    packageInfo: await PackageInfo.fromPlatform(),
    androidInfo: await DeviceInfoPlugin().androidInfo,
  );
}

@riverpod
BlockedTagsRepo blockedTagsRepo(BlockedTagsRepoRef ref) {
  final box = Hive.box<BooruTag>(BlockedTagsRepoImpl.boxKey);
  return BlockedTagsRepoImpl(box);
}

@riverpod
BooruRepo booruRepo(BooruRepoRef ref, ServerData server) {
  return BooruRepoImpl(
    client: ref.watch(dioProvider),
    server: server,
  );
}

@riverpod
ChangelogRepo changelogRepo(ChangelogRepoRef ref) {
  return ChangelogRepoImpl(
    bundle: rootBundle,
    client: ref.watch(dioProvider),
  );
}

@riverpod
FavoritePostRepo favoritePostRepo(FavoritePostRepoRef ref) {
  final box = Hive.box<FavoritePost>(FavoritePostRepoImpl.key);
  return FavoritePostRepoImpl(box);
}

@riverpod
SearchHistoryRepo searchHistoryRepo(SearchHistoryRepoRef ref) {
  final box = Hive.box<SearchHistory>(SearchHistoryRepoImpl.key);
  return SearchHistoryRepoImpl(box);
}

@riverpod
ServerRepo serverRepo(ServerRepoRef ref) {
  final box = Hive.box<ServerData>(ServerRepoImpl.key);
  final defaultServers = ref.watch(defaultServersProvider);
  return ServerRepoImpl(defaultServers: defaultServers, box: box);
}

@riverpod
SettingRepo settingRepo(SettingRepoRef ref) {
  final box = Hive.box(SettingRepoImpl.key);
  return SettingRepoImpl(box);
}

@riverpod
VersionRepo versionRepo(VersionRepoRef ref) {
  return VersionRepoImpl(
    envRepo: ref.watch(envRepoProvider),
    client: ref.watch(dioProvider),
  );
}

@riverpod
DownloadRepo downloadRepo(DownloadRepoRef ref) {
  final entryBox = Hive.box<DownloadEntry>(DownloadRepoImpl.entryKey);
  final progressBox = Hive.box<DownloadProgress>(DownloadRepoImpl.progressKey);
  return DownloadRepoImpl(entryBox: entryBox, progressBox: progressBox);
}

@riverpod
AppStateRepo appStateRepo(AppStateRepoRef ref) {
  final box = AppStateRepoImpl.hiveBox();
  return AppStateRepoImpl(box);
}
