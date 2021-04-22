import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        accentColor: Colors.blue,
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
  runApp(ProviderScope(child: Boorusphere()));
}
