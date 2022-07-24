import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedThemeMode =
    FutureProvider<ThemeMode>((ref) async => await ThemeModeState.restore(ref));

final themeModeProvider =
    StateNotifierProvider<ThemeModeState, ThemeMode>((ref) {
  final fromSettings = ref
      .watch(_savedThemeMode)
      .maybeWhen(data: (data) => data, orElse: () => ThemeMode.system);

  return ThemeModeState(ref, fromSettings);
});

final _savedDarkerTheme =
    FutureProvider<bool>((ref) async => await DarkerThemeState.restore(ref));

final darkerThemeProvider =
    StateNotifierProvider<DarkerThemeState, bool>((ref) {
  final fromSettings = ref
      .watch(_savedDarkerTheme)
      .maybeWhen(data: (data) => data, orElse: () => false);

  return DarkerThemeState(ref, fromSettings);
});

class ThemeModeState extends StateNotifier<ThemeMode> {
  ThemeModeState(this.ref, ThemeMode initState) : super(initState);

  final Ref ref;

  Future<void> setMode({required ThemeMode mode}) async {
    state = mode;
    final settings = await ref.read(settingsBox);
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

  static Future<ThemeMode> restore(FutureProviderRef futureRef) async {
    final settings = await futureRef.read(settingsBox);
    final value = settings.get(boxKey, defaultValue: ThemeMode.system.index);
    return ThemeMode.values[value];
  }

  static const boxKey = 'theme_mode';
}

class DarkerThemeState extends StateNotifier<bool> {
  DarkerThemeState(this.ref, bool initState) : super(initState);

  final Ref ref;

  void enable(bool value) async {
    state = value;
    final prefs = await ref.read(settingsBox);
    prefs.put(boxKey, value);
  }

  static const boxKey = 'ui_theme_darker';

  static Future<bool> restore(FutureProviderRef futureRef) async {
    final settings = await futureRef.read(settingsBox);
    return settings.get(boxKey, defaultValue: false);
  }
}
