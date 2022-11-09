import 'package:boorusphere/services/app_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppThemeBuilder extends ConsumerWidget {
  const AppThemeBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, AppThemeData appTheme) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    return DynamicColorBuilder(
      builder: (light, dark) => builder(
        context,
        appTheme.fillWith(light: light, dark: dark),
      ),
    );
  }
}
