import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'entity/download_entry.dart';
import 'entity/post.dart';
import 'entity/search_history.dart';
import 'entity/server_data.dart';
import 'screens/app_router.dart';
import 'services/app_theme/app_theme.dart';
import 'source/device_info.dart';
import 'source/settings/theme.dart';

class Boorusphere extends HookConsumerWidget {
  Boorusphere({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appTheme = ref.watch(appThemeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);

    if (deviceInfo.sdkInt > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return DynamicColorBuilder(
      builder: (maybeLight, maybeDark) {
        appTheme.overrideWith(light: maybeLight, dark: maybeDark);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Boorusphere',
          theme: appTheme.data.day,
          darkTheme:
              isDarkerTheme ? appTheme.data.midnight : appTheme.data.night,
          themeMode: themeMode,
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
        );
      },
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
  ];

  await Hive.initFlutter();
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  await Future.wait(boxes.map(Hive.openBox));

  runApp(ProviderScope(child: Boorusphere()));
}
