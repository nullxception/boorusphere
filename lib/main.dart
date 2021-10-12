import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/search_history.dart';
import 'model/server_data.dart';
import 'provider/app_theme.dart';
import 'routes.dart';

class Boorusphere extends HookConsumerWidget {
  const Boorusphere({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boorusphere',
      theme: AppTheme.light(),
      darkTheme: appTheme.isDarkerTheme ? AppTheme.darker() : AppTheme.dark(),
      themeMode: appTheme.current,
      initialRoute: Routes.home,
      routes: Routes.of(context),
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
