import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeState, ThemeMode>((ref) {
  final box = Hive.box('settings');
  final fromSettings =
      box.get(ThemeModeState.boxKey, defaultValue: ThemeMode.system.index);
  return ThemeModeState(ref, ThemeMode.values[fromSettings]);
});

final darkerThemeProvider =
    StateNotifierProvider<DarkerThemeState, bool>((ref) {
  final box = Hive.box('settings');
  final fromSettings = box.get(DarkerThemeState.boxKey, defaultValue: false);
  return DarkerThemeState(ref, fromSettings);
});

class ThemeModeState extends StateNotifier<ThemeMode> {
  ThemeModeState(this.ref, ThemeMode initState) : super(initState);

  final Ref ref;

  void setMode({required ThemeMode mode}) {
    state = mode;
    Hive.box('settings').put(boxKey, mode.index);
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

  static const boxKey = 'theme_mode';
}

class DarkerThemeState extends StateNotifier<bool> {
  DarkerThemeState(this.ref, bool initState) : super(initState);

  final Ref ref;

  void enable(bool value) {
    state = value;
    Hive.box('settings').put(boxKey, value);
  }

  static const boxKey = 'ui_theme_darker';
}
