import 'package:dynamic_color/dynamic_color.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/download_entry.dart';
import 'data/post.dart';
import 'data/search_history.dart';
import 'data/server_data.dart';
import 'providers/app_theme.dart';
import 'providers/downloader.dart';
import 'providers/page_manager.dart';
import 'providers/settings/theme.dart';
import 'routes.dart';
import 'widgets/bouncing_scroll.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appTheme = ref.watch(appThemeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);

    useEffect(() {
      ref.read(pageManagerProvider).initialize();
      ref.read(downloadProvider.notifier).register();
      return () {
        ref.read(downloadProvider.notifier).unregister();
      };
    }, []);

    return DynamicColorBuilder(
      builder: (ColorScheme? maybeLight, ColorScheme? maybeDark) {
        appTheme.overrideWith(light: maybeLight, dark: maybeDark);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Boorusphere',
          theme: appTheme.data.day,
          darkTheme:
              isDarkerTheme ? appTheme.data.midnight : appTheme.data.night,
          themeMode: themeMode,
          initialRoute: Routes.home,
          routes: Routes.of(context),
          builder: (context, widget) => ScrollConfiguration(
            behavior: const BouncingScrollBehavior(),
            child: widget ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

void main() async {
  Fimber.plantTree(DebugTree());
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
  await Future.wait(boxes.map((box) => Hive.openBox(box)));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: Boorusphere()));
}
