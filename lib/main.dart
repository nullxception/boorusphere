import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
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
import 'package:boorusphere/presentation/boorusphere.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/device_prop.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  Hive.registerAdapter(FavoritePostAdapter());

  await Future.wait([
    ServerLocalSource.prepare(),
    BlockedTagsLocalSource.prepare(),
    FavoritePostLocalSource.prepare(),
    SearchHistoryLocalSource.prepare(),
    SettingLocalSource.prepare(),
    DownloaderSource.prepare(),
  ]);

  final deviceProp = DeviceProp(await DeviceInfoPlugin().androidInfo);

  runApp(
    ProviderScope(
      overrides: [
        devicePropProvider.overrideWithValue(deviceProp),
      ],
      child: TranslationProvider(child: const Boorusphere()),
    ),
  );
}
