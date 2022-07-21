import 'package:dynamic_color/dynamic_color.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/booru_post.dart';
import 'model/download_entry.dart';
import 'model/search_history.dart';
import 'model/server_data.dart';
import 'provider/booru_api.dart';
import 'provider/downloader.dart';
import 'provider/server_data.dart';
import 'provider/settings/active_server.dart';
import 'provider/settings/theme.dart';
import 'routes.dart';
import 'util/app_theme.dart';
import 'views/components/bouncing_scroll.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({super.key});

  Future<void> initServerData(WidgetRef ref) async {
    final api = ref.read(booruApiProvider);
    final serverDataNotifier = ref.read(serverDataProvider.notifier);
    final activeServerNotifier = ref.read(activeServerProvider.notifier);

    await serverDataNotifier.populateData();
    await activeServerNotifier.restoreFromPreference();
    api.posts.clear();
    api.fetch();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkerTheme = ref.watch(darkerThemeProvider);
    final downloadNotifier = ref.watch(downloadProvider.notifier);

    useEffect(() {
      initServerData(ref);
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

  await Hive.initFlutter();
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(BooruPostAdapter());
  Hive.registerAdapter(DownloadEntryAdapter());

  runApp(const ProviderScope(child: Boorusphere()));
}
