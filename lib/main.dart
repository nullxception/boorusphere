import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/app_state/current_app_state_repo.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_status.dart';
import 'package:boorusphere/data/repository/downloads/user_download_repo.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/favorite_post/user_favorite_post_repo.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/search_history/user_search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/server/user_server_repo.dart';
import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/data/repository/tags_blocker/booru_tags_blocker_repo.dart';
import 'package:boorusphere/data/repository/tags_blocker/entity/booru_tag.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/boorusphere.dart';
import 'package:boorusphere/presentation/i18n/helper.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:boorusphere/presentation/provider/shared_storage_handle.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ServerAdapter());
  Hive.registerAdapter(BooruTagAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  Hive.registerAdapter(FavoritePostAdapter());
  Hive.registerAdapter(BooruRatingAdapter());
  Hive.registerAdapter(DownloadQualityAdapter());
  Hive.registerAdapter(DownloadStatusAdapter());
  Hive.registerAdapter(DownloadProgressAdapter());

  await Future.wait([
    UserServerRepo.prepare(),
    BooruTagsBlockerRepo.prepare(),
    UserFavoritePostRepo.prepare(),
    UserSearchHistoryRepo.prepare(),
    UserSettingsRepo.prepare(),
    UserDownloadsRepo.prepare(),
    CurrentAppStateRepo.prepare(),
  ]);

  LocaleHelper.setupPluralResolver();

  runApp(
    ProviderScope(
      overrides: [
        sharedStorageHandleProvider
            .overrideWithValue(await provideSharedStorageHandle()),
        cookieJarProvider.overrideWithValue(await provideCookieJar()),
        defaultServersProvider.overrideWithValue(await provideDefaultServers()),
        envRepoProvider.overrideWithValue(await provideEnvRepo()),
      ],
      child: TranslationProvider(child: const Boorusphere()),
    ),
  );
}
