import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/search_history.dart';
import 'model/server_data.dart';
import 'provider/app_theme.dart';
import 'provider/downloader.dart';
import 'routes.dart';
import 'views/components/bouncing_scroll.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    final downloadNotifier = ref.watch(downloadProvider.notifier);

    useEffect(() {
      downloadNotifier.register();
      return () {
        downloadNotifier.unregister();
      };
    }, []);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boorusphere',
      theme: AppTheme.light(),
      darkTheme: appTheme.isDarkerTheme ? AppTheme.darker() : AppTheme.dark(),
      themeMode: appTheme.current,
      initialRoute: Routes.home,
      routes: Routes.of(context),
      builder: (context, widget) => ScrollConfiguration(
        behavior: const BouncingScrollBehavior(),
        child: widget ?? const SizedBox.shrink(),
      ),
    );
  }
}

void main() async {
  Fimber.plantTree(DebugTree());

  await Hive.initFlutter();
  Hive.registerAdapter(ServersAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());

  runApp(const ProviderScope(child: Boorusphere()));
}
