import 'package:boorusphere/data/provider/dio.dart';
import 'package:boorusphere/data/repository/blocked_tags/blocked_tags_repo_impl.dart';
import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/booru/booru_repo_impl.dart';
import 'package:boorusphere/data/repository/booru/datasource/booru_network_source.dart';
import 'package:boorusphere/data/repository/changelog/changelog_repo_impl.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_local_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_network_source.dart';
import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/favorite_post/favorite_post_repo_impl.dart';
import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/search_history/search_history_repo_impl.dart';
import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/server/server_repo_impl.dart';
import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/data/repository/setting/setting_repo_impl.dart';
import 'package:boorusphere/data/repository/version/datasource/version_local_source.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/version_repo_impl.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:boorusphere/domain/repository/booru_repo.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';
import 'package:boorusphere/domain/repository/server_repo.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final blockedTagsRepoProvider = Provider<BlockedTagsRepo>((ref) {
  final box = Hive.box<String>(BlockedTagsLocalSource.key);
  return BlockedTagsRepoImpl(
    localSource: BlockedTagsLocalSource(box),
  );
});

final booruRepoProvider = Provider.family<BooruRepo, ServerData>((ref, server) {
  final dio = ref.watch(dioProvider);
  return BooruRepoImpl(
    networkSource: BooruNetworkSource(dio),
    server: server,
  );
});

final changelogRepoProvider = Provider<ChangelogRepo>((ref) {
  final dio = ref.watch(dioProvider);
  return ChangelogRepoImpl(
    localSource: ChangelogLocalSource(rootBundle),
    networkSource: ChangelogNetworkSource(dio),
  );
});

final favoritePostRepoProvider = Provider<FavoritePostRepo>((ref) {
  final box = Hive.box<FavoritePost>(FavoritePostLocalSource.key);
  return FavoritePostRepoImpl(
    localSource: FavoritePostLocalSource(box),
  );
});

final searchHistoryRepoProvider = Provider<SearchHistoryRepo>((ref) {
  final box = Hive.box<SearchHistory>(SearchHistoryLocalSource.key);
  return SearchHistoryRepoImpl(
    localSource: SearchHistoryLocalSource(box),
  );
});

final serverRepoProvider = Provider<ServerRepo>((ref) {
  final box = Hive.box<ServerData>(ServerLocalSource.key);
  return ServerRepoImpl(
    localSource: ServerLocalSource(assetBundle: rootBundle, box: box),
  );
});

final settingRepoProvider = Provider<SettingRepo>((ref) {
  final box = Hive.box(SettingLocalSource.key);
  return SettingRepoImpl(
    localSource: SettingLocalSource(box),
  );
});

final versionRepoProvider = Provider<VersionRepo>((ref) {
  final dio = ref.watch(dioProvider);
  return VersionRepoImpl(
    localSource: VersionLocalSource(),
    networkSource: VersionNetworkSource(dio),
  );
});
