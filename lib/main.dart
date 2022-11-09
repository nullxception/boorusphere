import 'package:boorusphere/data/entity/download_entry.dart';
import 'package:boorusphere/data/entity/favorite_post.dart';
import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/entity/search_history.dart';
import 'package:boorusphere/data/entity/server_data.dart';
import 'package:boorusphere/data/source/device_info.dart';
import 'package:boorusphere/data/source/settings/settings.dart';
import 'package:boorusphere/presentation/boorusphere.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const boxes = [
    'searchHistory',
    'settings',
    'server',
    'blockedTags',
    'downloads',
    'favorites',
  ];

  await Hive.initFlutter();
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  Hive.registerAdapter(FavoritePostAdapter());
  await Future.wait(boxes.map(Hive.openBox));
  await Settings.performMigration();
  await FlutterDownloader.initialize();

  final deviceInfo = DeviceInfoSource(await DeviceInfoPlugin().androidInfo);

  runApp(
    ProviderScope(
      overrides: [
        deviceInfoProvider.overrideWithValue(deviceInfo),
      ],
      child: const Boorusphere(),
    ),
  );
}
