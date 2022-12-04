import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/blocked_tags/blocked_tags_repo_impl.dart';
import 'package:boorusphere/data/repository/booru/booru_repo_impl.dart';
import 'package:boorusphere/data/repository/changelog/changelog_repo_impl.dart';
import 'package:boorusphere/data/repository/download/download_repo_impl.dart';
import 'package:boorusphere/data/repository/env/env_repo_impl.dart';
import 'package:boorusphere/data/repository/favorite_post/favorite_post_repo_impl.dart';
import 'package:boorusphere/data/repository/search_history/search_history_repo_impl.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/server/server_repo_impl.dart';
import 'package:boorusphere/data/repository/setting/setting_repo_impl.dart';
import 'package:boorusphere/data/repository/version/version_repo_impl.dart';
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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
BlockedTagsRepo blockedTagsRepo(BlockedTagsRepoRef ref) {
  return BlockedTagsRepoImpl(
    localSource: ref.watch(blockedTagsLocalSourceProvider),
  );
}

@riverpod
BooruRepo booruRepo(BooruRepoRef ref, ServerData server) {
  return BooruRepoImpl(
    networkSource: ref.watch(booruNetworkSourceProvider),
    server: server,
  );
}

@riverpod
ChangelogRepo changelogRepo(ChangelogRepoRef ref) {
  return ChangelogRepoImpl(
    localSource: ref.watch(changelogLocalSourceProvider),
    networkSource: ref.watch(changelogNetworkSourceProvider),
  );
}

@riverpod
FavoritePostRepo favoritePostRepo(FavoritePostRepoRef ref) {
  return FavoritePostRepoImpl(
    localSource: ref.watch(favoritePostLocalSourceProvider),
  );
}

@riverpod
SearchHistoryRepo searchHistoryRepo(SearchHistoryRepoRef ref) {
  return SearchHistoryRepoImpl(
    localSource: ref.watch(searchHistoryLocalSourceProvider),
  );
}

@riverpod
ServerRepo serverRepo(ServerRepoRef ref) {
  return ServerRepoImpl(
    localSource: ref.watch(serverLocalSourceProvider),
  );
}

@riverpod
SettingRepo settingRepo(SettingRepoRef ref) {
  return SettingRepoImpl(
    localSource: ref.watch(settingLocalSourceProvider),
  );
}

@riverpod
VersionRepo versionRepo(VersionRepoRef ref) {
  return VersionRepoImpl(
    localSource: ref.watch(versionLocalSourceProvider),
    networkSource: ref.watch(versionNetworkSourceProvider),
  );
}

@riverpod
DownloadRepo downloadRepo(DownloadRepoRef ref) {
  return DownloadRepoImpl(
    ref.watch(downloaderSourceProvider),
  );
}

@Riverpod(keepAlive: true)
EnvRepo envRepo(EnvRepoRef ref) {
  throw UnimplementedError('must be initialized manually');
}

extension EnvRepoProviderExt on Provider<EnvRepo> {
  Future<Override> initialize() async {
    return overrideWithValue(
      EnvRepoImpl(
        packageInfo: await PackageInfo.fromPlatform(),
        androidInfo: await DeviceInfoPlugin().androidInfo,
      ),
    );
  }
}
