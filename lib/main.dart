import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/search_history.dart';
import 'model/server_data.dart';
import 'provider/app_theme.dart';
import 'routes.dart';

class Boorusphere extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final appTheme = useProvider(appThemeProvider);
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

  runApp(ProviderScope(child: Boorusphere()));
}
