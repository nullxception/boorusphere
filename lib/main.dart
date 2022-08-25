import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'entity/download_entry.dart';
import 'entity/post.dart';
import 'entity/search_history.dart';
import 'entity/server_data.dart';
import 'routes/routes.dart';
import 'source/device_info.dart';
import 'source/settings/theme.dart';
import 'widgets/apptheme.dart';

class Boorusphere extends HookConsumerWidget {
  Boorusphere({super.key});

  final _router = SphereRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);

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
        routerDelegate: _router.delegate(),
        routeInformationParser: _router.defaultRouteParser(),
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
  ];

  await Hive.initFlutter();
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());
  await Future.wait(boxes.map(Hive.openBox));

  runApp(ProviderScope(child: Boorusphere()));
}
