import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/settings.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeState, ThemeMode>((ref) {
  final fromSettings = Settings.theme_mode.read(or: ThemeMode.system.index);
  return ThemeModeState(ThemeMode.values[fromSettings]);
});

final darkerThemeProvider =
    StateNotifierProvider<DarkerThemeState, bool>((ref) {
  final fromSettings = Settings.ui_theme_darker.read(or: false);
  return DarkerThemeState(fromSettings);
});

class ThemeModeState extends StateNotifier<ThemeMode> {
  ThemeModeState(super.initState);

  void setMode({required ThemeMode mode}) {
    state = mode;
    Settings.theme_mode.save(mode.index);
  }

  void cycleTheme() {
    switch (state) {
      case ThemeMode.dark:
        setMode(mode: ThemeMode.light);
        break;
      case ThemeMode.light:
        setMode(mode: ThemeMode.system);
        break;
      default:
        setMode(mode: ThemeMode.dark);
        break;
    }
  }
}

class DarkerThemeState extends StateNotifier<bool> {
  DarkerThemeState(super.initState);

  void enable(bool value) {
    state = value;
    Settings.ui_theme_darker.save(value);
  }
}
