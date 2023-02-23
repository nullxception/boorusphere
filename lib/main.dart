import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/datasource/downloader_source.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
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
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(BooruTagAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  Hive.registerAdapter(FavoritePostAdapter());
  Hive.registerAdapter(BooruRatingAdapter());

  await Future.wait([
    ServerLocalSource.prepare(),
    BlockedTagsLocalSource.prepare(),
    FavoritePostLocalSource.prepare(),
    SearchHistoryLocalSource.prepare(),
    SettingLocalSource.prepare(),
    DownloaderSource.prepare(),
  ]);

  LocaleHelper.useFallbackPluralResolver([
    AppLocale.fil,
    AppLocale.idId,
    AppLocale.jaJp,
    AppLocale.thTh,
    AppLocale.trTr,
    AppLocale.ru,
    AppLocale.uk
  ]);

  runApp(
    ProviderScope(
      overrides: [
        await cookieJarProvider.initialize(),
        await envRepoProvider.initialize(),
      ],
      child: TranslationProvider(child: const Boorusphere()),
    ),
  );
}
