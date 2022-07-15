import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'hive_boxes.dart';

class AppThemeNotifier extends ChangeNotifier {
  static const keyThemeMode = 'ui_theme_mode';
  static const keyThemeDarker = 'ui_theme_darker';
  final Reader read;
  bool _isDarker = false;
  ThemeMode _current = ThemeMode.system;

  final lightColorsDefault = ColorScheme.fromSeed(seedColor: AppTheme.idAccent);
  final darkColorsDefault = ColorScheme.fromSeed(
      seedColor: AppTheme.idAccent, brightness: Brightness.dark);

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

  ThemeData schemeFrom(ColorScheme? scheme, Brightness brightness) {
    final colors = scheme?.harmonized();

    if (brightness == Brightness.light) {
      return AppTheme.light(colors ?? lightColorsDefault);
    } else if (isDarkerTheme) {
      return AppTheme.darker(colors ?? darkColorsDefault);
    } else {
      return AppTheme.dark(colors ?? darkColorsDefault);
    }
  }
}

mixin AppTheme {
  static const idAccent = Color.fromARGB(255, 149, 30, 229);

  static ThemeData light(ColorScheme seededScheme) =>
      ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: seededScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: seededScheme.surface,
          foregroundColor: seededScheme.onSurface,
          elevation: 0,
        ),
        backgroundColor: seededScheme.surface,
        canvasColor: seededScheme.surface,
        cardColor: seededScheme.surface.darken(2),
        scaffoldBackgroundColor: seededScheme.surface,
        toggleableActiveColor: seededScheme.primary,
      );

  static ThemeData dark(ColorScheme seededScheme) => ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: seededScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: seededScheme.surface.darken(2),
          foregroundColor: seededScheme.onSurface,
          elevation: 0,
        ),
        backgroundColor: seededScheme.surface,
        canvasColor: seededScheme.surface,
        cardColor: seededScheme.surface.lighten(3),
        scaffoldBackgroundColor: seededScheme.surface.darken(2),
        toggleableActiveColor: seededScheme.primary,
      );

  static ThemeData darker(ColorScheme seededScheme) =>
      ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: seededScheme.copyWith(
          brightness: Brightness.dark,
          surface: seededScheme.background,
          background: Colors.black,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: seededScheme.onSurface,
          elevation: 0,
        ),
        primaryColor: Colors.black,
        backgroundColor: Colors.black,
        canvasColor: Colors.black,
        cardColor: seededScheme.background.darken(3),
        scaffoldBackgroundColor: Colors.black,
        toggleableActiveColor: seededScheme.primary,
      );
}

final appThemeProvider =
    ChangeNotifierProvider((ref) => AppThemeNotifier(ref.read));
