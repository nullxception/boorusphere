import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/app_state/app_state_repo_impl.dart';
import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/datasource/downloader_source.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/boorusphere.dart';
import 'package:boorusphere/presentation/i18n/helper.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:boorusphere/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await FileUtils.initialize();

  Hive.registerAdapter(ServersAdapter());
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
    ServerLocalSource.prepare(),
    BlockedTagsLocalSource.prepare(),
    FavoritePostLocalSource.prepare(),
    SearchHistoryLocalSource.prepare(),
    SettingLocalSource.prepare(),
    DownloaderSource.prepare(),
    AppStateRepoImpl.prepare(),
  ]);

  LocaleHelper.useFallbackPluralResolver([
    AppLocale.fil,
    AppLocale.idId,
    AppLocale.jaJp,
    AppLocale.thTh,
    AppLocale.trTr,
    AppLocale.ru,
    AppLocale.uk,
    AppLocale.uwu,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        cookieJarProvider.overrideWithValue(await provideCookieJar()),
        defaultServersProvider.overrideWithValue(await provideDefaultServers()),
        envRepoProvider.overrideWithValue(await provideEnvRepo()),
      ],
      child: TranslationProvider(child: const Boorusphere()),
    ),
  );
}
