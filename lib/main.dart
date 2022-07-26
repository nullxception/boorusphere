import 'package:dynamic_color/dynamic_color.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/download_entry.dart';
import 'model/post.dart';
import 'model/search_history.dart';
import 'model/server_data.dart';
import 'provider/downloader.dart';
import 'provider/page_manager.dart';
import 'provider/settings/theme.dart';
import 'routes.dart';
import 'util/app_theme.dart';
import 'views/components/bouncing_scroll.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);
    final downloadNotifier = ref.watch(downloadProvider.notifier);
    final pageManager = ref.read(pageManagerProvider);

    useEffect(() {
      pageManager.initialize();
      downloadNotifier.register();
      return () {
        downloadNotifier.unregister();
      };
    }, []);

    return DynamicColorBuilder(
      builder: (ColorScheme? maybeLight, ColorScheme? maybeDark) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Boorusphere',
        theme: AppTheme.schemeFrom(maybeLight, AppThemeVariant.light),
        darkTheme: AppTheme.schemeFrom(maybeDark,
            isDarkerTheme ? AppThemeVariant.darker : AppThemeVariant.dark),
        themeMode: themeMode,
        initialRoute: Routes.home,
        routes: Routes.of(context),
        builder: (context, widget) => ScrollConfiguration(
          behavior: const BouncingScrollBehavior(),
          child: widget ?? const SizedBox.shrink(),
        ),
      ),
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
