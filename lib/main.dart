import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'model/search_history.dart';
import 'model/server_data.dart';
import 'provider/common.dart';
import 'routes.dart';

class Boorusphere extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boorusphere',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          accentColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        toggleableActiveColor: Colors.blue.shade300,
      ),
      themeMode: watch(uiThemeProvider),
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
