import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_boxes.dart';

class AppThemeNotifier extends ChangeNotifier {
  static const keyThemeMode = 'ui_theme_mode';
  static const keyThemeDarker = 'ui_theme_darker';
  final Reader read;
  bool _isDarker = false;
  ThemeMode _current = ThemeMode.system;

  AppThemeNotifier(this.read) {
    _init();
  }

  get current => _current;
  get isDarkerTheme => _isDarker;

  Future<void> _init() async {
    final prefs = await read(settingsBox);
    final modeString = prefs.get(keyThemeMode);
    switch (modeString) {
      case 'dark':
        _current = ThemeMode.dark;
        break;
      case 'light':
        _current = ThemeMode.light;
        break;
      default:
        _current = ThemeMode.system;
    }

    final darkerTheme = prefs.get(keyThemeDarker);
    _isDarker = darkerTheme ?? false;
    notifyListeners();
  }

  Future<void> setMode({required ThemeMode mode}) async {
    _current = mode;
    final prefs = await read(settingsBox);
    switch (mode) {
      case ThemeMode.dark:
        prefs.put(keyThemeMode, 'dark');
        break;
      case ThemeMode.light:
        prefs.put(keyThemeMode, 'light');
        break;
      default:
        prefs.put(keyThemeMode, 'system');
    }
    notifyListeners();
  }

  IconData get themeIcon {
    switch (_current) {
      case ThemeMode.dark:
        return Icons.brightness_2;
      case ThemeMode.light:
        return Icons.brightness_high;
      default:
        return Icons.brightness_auto;
    }
  }

  void cycleTheme() async {
    switch (_current) {
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

  void useDarkerTheme(value) async {
    _isDarker = value;
    notifyListeners();
    final prefs = await read(settingsBox);
    prefs.put(keyThemeDarker, value);
  }
}

mixin AppTheme {
  static ThemeData light() => ThemeData.light();

  static ThemeData dark() => ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          accentColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        toggleableActiveColor: Colors.blue.shade300,
      );

  static ThemeData darker() => ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          accentColor: Colors.blue,
          brightness: Brightness.dark,
          cardColor: Colors.black.withRed(20).withGreen(20).withBlue(20),
          backgroundColor: Colors.black,
        ),
        primaryColor: Colors.black,
        backgroundColor: Colors.black,
        canvasColor: Colors.black,
        cardColor: Colors.black.withRed(20).withGreen(20).withBlue(20),
        scaffoldBackgroundColor: Colors.black,
        toggleableActiveColor: Colors.blue.shade300,
      );
}

final appThemeProvider =
    ChangeNotifierProvider((ref) => AppThemeNotifier(ref.read));
