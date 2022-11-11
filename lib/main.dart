import 'package:boorusphere/data/entity/download_entry.dart';
import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/migrator/setting_migrator.dart';
import 'package:boorusphere/presentation/boorusphere.dart';
import 'package:boorusphere/presentation/provider/device_prop.dart';
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
  await migrateSetting();
  await FlutterDownloader.initialize();

  final deviceProp = DeviceProp(await DeviceInfoPlugin().androidInfo);

  runApp(
    ProviderScope(
      overrides: [
        devicePropProvider.overrideWithValue(deviceProp),
      ],
      child: const Boorusphere(),
    ),
  );
}
