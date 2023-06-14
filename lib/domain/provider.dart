import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/app_state/current_app_state_repo.dart';
import 'package:boorusphere/data/repository/booru/booru_repo.dart';
import 'package:boorusphere/data/repository/booru/provider.dart';
import 'package:boorusphere/data/repository/changelog/app_changelog_repo.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';
import 'package:boorusphere/data/repository/downloads/user_download_repo.dart';
import 'package:boorusphere/data/repository/env/current_env_repo.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/favorite_post/user_favorite_post_repo.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/search_history/user_search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/server/entity/server_auth.dart';
import 'package:boorusphere/data/repository/server/user_server_repo.dart';
import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/data/repository/tags_blocker/booru_tags_blocker_repo.dart';
import 'package:boorusphere/data/repository/tags_blocker/entity/booru_tag.dart';
import 'package:boorusphere/data/repository/version/app_version_repo.dart';
import 'package:boorusphere/domain/repository/app_state_repo.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:boorusphere/domain/repository/downloads_repo.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:boorusphere/domain/repository/imageboards_repo.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';
import 'package:boorusphere/domain/repository/server_data_repo.dart';
import 'package:boorusphere/domain/repository/settings_repo.dart';
import 'package:boorusphere/domain/repository/tags_blocker_repo.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:boorusphere/pigeon/app_env.pi.dart';
import 'package:boorusphere/presentation/provider/server_auth_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
EnvRepo envRepo(EnvRepoRef ref) {
  throw UnimplementedError('must be initialized manually');
}

Future<EnvRepo> provideEnvRepo() async {
  return CurrentEnvRepo(env: await AppEnv().get());
}

@riverpod
TagsBlockerRepo tagsBlockerRepo(TagsBlockerRepoRef ref) {
  final box = Hive.box<BooruTag>(BooruTagsBlockerRepo.boxKey);
  return BooruTagsBlockerRepo(box);
}

@riverpod
ImageboardRepo imageboardRepo(ImageboardRepoRef ref, Server server) {
  return BooruRepo(
    parsers: ref.watch(booruParsersProvider),
    client: ref.watch(dioProvider),
    server: server,
    auth: ref.watch(serverAuthStateProvider).on(server),
    serverState: ref.watch(serverStateProvider.notifier),
  );
}

@riverpod
ChangelogRepo changelogRepo(ChangelogRepoRef ref) {
  return AppChangelogRepo(
    bundle: rootBundle,
    client: ref.watch(dioProvider),
  );
}

@riverpod
FavoritePostRepo favoritePostRepo(FavoritePostRepoRef ref) {
  final box = Hive.box<FavoritePost>(UserFavoritePostRepo.key);
  return UserFavoritePostRepo(box);
}

@riverpod
SearchHistoryRepo searchHistoryRepo(SearchHistoryRepoRef ref) {
  final box = Hive.box<SearchHistory>(UserSearchHistoryRepo.key);
  return UserSearchHistoryRepo(box);
}

@riverpod
ServerRepo serverRepo(ServerRepoRef ref) {
  return UserServerRepo(
    defaultServers: ref.watch(defaultServersProvider),
    box: Hive.box<Server>(UserServerRepo.key),
    authBox: Hive.box<ServerAuth>(UserServerRepo.authKey),
  );
}

@riverpod
SettingsRepo settingsRepo(SettingsRepoRef ref) {
  final box = Hive.box(UserSettingsRepo.key);
  return UserSettingsRepo(box);
}

@riverpod
VersionRepo versionRepo(VersionRepoRef ref) {
  return AppVersionRepo(
    envRepo: ref.watch(envRepoProvider),
    client: ref.watch(dioProvider),
  );
}

@riverpod
DownloadsRepo downloadsRepo(DownloadsRepoRef ref) {
  final entryBox = Hive.box<DownloadEntry>(UserDownloadsRepo.entryKey);
  final progressBox = Hive.box<DownloadProgress>(UserDownloadsRepo.progressKey);
  return UserDownloadsRepo(entryBox: entryBox, progressBox: progressBox);
}

@riverpod
AppStateRepo appStateRepo(AppStateRepoRef ref) {
  final box = CurrentAppStateRepo.hiveBox();
  return CurrentAppStateRepo(box);
}
