import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedThemeMode =
    FutureProvider<ThemeMode>((ref) async => await ThemeModeState.restore(ref));

final themeModeProvider =
    StateNotifierProvider<ThemeModeState, ThemeMode>((ref) {
  final fromSettings = ref
      .read(_savedThemeMode)
      .maybeWhen(data: (data) => data, orElse: () => ThemeMode.system);

  return ThemeModeState(ref.read, fromSettings);
});

final _savedDarkerTheme =
    FutureProvider<bool>((ref) async => await DarkerThemeState.restore(ref));

final darkerThemeProvider =
    StateNotifierProvider<DarkerThemeState, bool>((ref) {
  final fromSettings = ref
      .read(_savedDarkerTheme)
      .maybeWhen(data: (data) => data, orElse: () => false);

  return DarkerThemeState(ref.read, fromSettings);
});

class ThemeModeState extends StateNotifier<ThemeMode> {
  ThemeModeState(this.read, ThemeMode initState) : super(initState);

  final Reader read;

  Future<void> setMode({required ThemeMode mode}) async {
    state = mode;
    final settings = await read(settingsBox);
    settings.put(boxKey, mode.index);
  }

  void cycleTheme() async {
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

  static Future<ThemeMode> restore(FutureProviderRef ref) async {
    final settings = await ref.read(settingsBox);
    final value = settings.get(boxKey, defaultValue: ThemeMode.system.index);
    return ThemeMode.values[value];
  }

  static const boxKey = 'theme_mode';
}

class DarkerThemeState extends StateNotifier<bool> {
  DarkerThemeState(this.read, bool initState) : super(initState);

  final Reader read;

  void enable(bool value) async {
    state = value;
    final prefs = await read(settingsBox);
    prefs.put(boxKey, value);
  }

  static const boxKey = 'ui_theme_darker';

  static Future<bool> restore(FutureProviderRef<bool> ref) async {
    final settings = await ref.read(settingsBox);
    return settings.get(boxKey, defaultValue: false);
  }
}
