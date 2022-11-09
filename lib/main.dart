import 'package:boorusphere/entity/download_entry.dart';
import 'package:boorusphere/entity/favorite_post.dart';
import 'package:boorusphere/entity/post.dart';
import 'package:boorusphere/entity/search_history.dart';
import 'package:boorusphere/entity/server_data.dart';
import 'package:boorusphere/routes/routes.dart';
import 'package:boorusphere/source/device_info.dart';
import 'package:boorusphere/source/settings/settings.dart';
import 'package:boorusphere/source/settings/theme.dart';
import 'package:boorusphere/widgets/app_theme_builder.dart';
import 'package:boorusphere/widgets/bouncing_scroll.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);
    final router = useMemoized(SphereRouter.new);

    if (deviceInfo.sdkInt > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return AppThemeBuilder(
      builder: (context, appTheme) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Boorusphere',
        theme: appTheme.day,
        darkTheme: isDarkerTheme ? appTheme.midnight : appTheme.night,
        themeMode: themeMode,
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        builder: (context, child) => ScrollConfiguration(
          behavior: const BouncingScrollBehavior(),
          child: child ?? Container(),
        ),
      ),
    );
  }
}

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
