import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeState, ThemeMode>((ref) {
  final saved = Settings.theme_mode.read(or: ThemeMode.system.index);
  return ThemeModeState(ThemeMode.values[saved]);
});

final darkerThemeProvider =
    StateNotifierProvider<DarkerThemeState, bool>((ref) {
  final saved = Settings.ui_theme_darker.read(or: false);
  return DarkerThemeState(saved);
});

class ThemeModeState extends StateNotifier<ThemeMode> {
  ThemeModeState(super.state);

  Future<void> update(ThemeMode mode) async {
    state = mode;
    await Settings.theme_mode.save(mode.index);
  }

  Future<ThemeMode> cycle() async {
    switch (state) {
      case ThemeMode.dark:
        await update(ThemeMode.light);
        break;
      case ThemeMode.light:
        await update(ThemeMode.system);
        break;
      default:
        await update(ThemeMode.dark);
        break;
    }
    return state;
  }
}

class DarkerThemeState extends StateNotifier<bool> {
  DarkerThemeState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.ui_theme_darker.save(value);
  }
}
