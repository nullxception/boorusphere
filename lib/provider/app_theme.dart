import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_boxes.dart';

class AppThemeNotifier extends StateNotifier<ThemeMode> {
  static const key = 'ui_theme_mode';
  final Reader read;

  AppThemeNotifier(this.read) : super(ThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await read(settingsBox);
    final modeString = prefs.get(key);
    switch (modeString) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'light':
        state = ThemeMode.light;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setMode({required ThemeMode mode}) async {
    state = mode;
    final prefs = await read(settingsBox);
    switch (mode) {
      case ThemeMode.dark:
        prefs.put(key, 'dark');
        break;
      case ThemeMode.light:
        prefs.put(key, 'light');
        break;
      default:
        prefs.put(key, 'system');
    }
  }

  IconData get themeIcon {
    switch (state) {
      case ThemeMode.dark:
        return Icons.brightness_2;
      case ThemeMode.light:
        return Icons.brightness_high;
      default:
        return Icons.brightness_auto;
    }
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
}

final appThemeProvider = StateNotifierProvider<AppThemeNotifier, ThemeMode>(
    (ref) => AppThemeNotifier(ref.read));
