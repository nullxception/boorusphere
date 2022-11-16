import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/blocked_tags/blocked_tags_repo_impl.dart';
import 'package:boorusphere/data/repository/booru/booru_repo_impl.dart';
import 'package:boorusphere/data/repository/changelog/changelog_repo_impl.dart';
import 'package:boorusphere/data/repository/favorite_post/favorite_post_repo_impl.dart';
import 'package:boorusphere/data/repository/search_history/search_history_repo_impl.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/server/server_repo_impl.dart';
import 'package:boorusphere/data/repository/setting/setting_repo_impl.dart';
import 'package:boorusphere/data/repository/version/version_repo_impl.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';
import 'package:boorusphere/domain/repository/server_repo.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedTagsRepoProvider = Provider.autoDispose<BlockedTagsRepo>((ref) {
  return BlockedTagsRepoImpl(
    localSource: ref.watch(blockedTagsLocalSourceProvider),
  );
});

final booruRepoProvider =
    Provider.autoDispose.family<BooruRepo, ServerData>((ref, server) {
  return BooruRepoImpl(
    networkSource: ref.watch(booruNetworkSourceProvider),
    server: server,
  );
});

final changelogRepoProvider = Provider.autoDispose<ChangelogRepo>((ref) {
  return ChangelogRepoImpl(
    localSource: ref.watch(changelogLocalSourceProvider),
    networkSource: ref.watch(changelogNetworkSourceProvider),
  );
});

final favoritePostRepoProvider = Provider.autoDispose<FavoritePostRepo>((ref) {
  return FavoritePostRepoImpl(
    localSource: ref.watch(favoritePostLocalSourceProvider),
  );
});

final searchHistoryRepoProvider =
    Provider.autoDispose<SearchHistoryRepo>((ref) {
  return SearchHistoryRepoImpl(
    localSource: ref.watch(searchHistoryLocalSourceProvider),
  );
});

final serverRepoProvider = Provider.autoDispose<ServerRepo>((ref) {
  return ServerRepoImpl(
    localSource: ref.watch(serverLocalSourceProvider),
  );
});

final settingRepoProvider = Provider.autoDispose<SettingRepo>((ref) {
  return SettingRepoImpl(
    localSource: ref.watch(settingsLocalSourceProvider),
  );
});

final versionRepoProvider = Provider.autoDispose<VersionRepo>((ref) {
  return VersionRepoImpl(
    localSource: ref.watch(versionLocalSourceProvider),
    networkSource: ref.watch(versionNetworkSourceProvider),
  );
});
