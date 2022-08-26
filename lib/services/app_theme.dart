import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycolor2/tinycolor2.dart';

final appThemeProvider = Provider((_) => AppThemeService());

class AppThemeData {
  const AppThemeData({
    required this.day,
    required this.night,
    required this.midnight,
  });

  final ThemeData day;
  final ThemeData night;
  final ThemeData midnight;
}

class AppThemeService {
  late AppThemeData _data = _createData();

  AppThemeData get data => _data;

  AppThemeData fillWith({ColorScheme? light, ColorScheme? dark}) {
    _data = _createData(light: light, dark: dark);
    return _data;
  }

  AppThemeData _createData({ColorScheme? light, ColorScheme? dark}) {
    return AppThemeData(
      day: _createDay(light),
      night: _createNight(dark),
      midnight: _createMidnight(dark),
    );
  }

  ThemeData _createDay(ColorScheme? scheme) {
    final colorScheme = scheme?.harmonized() ?? defaultLightScheme;
    final origin = ThemeData.light();
    return origin.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surface.darken(2),
      scaffoldBackgroundColor: colorScheme.surface,
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: colorScheme.surface.shade(3),
      ),
      toggleableActiveColor: colorScheme.primary,
      snackBarTheme: origin.snackBarTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        backgroundColor: colorScheme.primaryContainer,
        contentTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
      listTileTheme: origin.listTileTheme.copyWith(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22),
      ),
    );
  }

  ThemeData _createNight(ColorScheme? scheme) {
    final colorScheme = scheme?.harmonized() ?? defaultDarkScheme;
    final origin = ThemeData.dark();
    return origin.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface.darken(2),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surface.lighten(3),
      scaffoldBackgroundColor: colorScheme.surface.darken(2),
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: colorScheme.surface.shade(40),
      ),
      toggleableActiveColor: colorScheme.primary,
      snackBarTheme: origin.snackBarTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        backgroundColor: colorScheme.primaryContainer,
        contentTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
      listTileTheme: origin.listTileTheme.copyWith(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22),
      ),
    );
  }

  ThemeData _createMidnight(ColorScheme? scheme) {
    final colorScheme = scheme?.harmonized() ?? defaultDarkScheme;
    final origin = ThemeData.dark();
    return origin.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: colorScheme.background,
        background: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      primaryColor: Colors.black,
      backgroundColor: Colors.black,
      canvasColor: Colors.black,
      cardColor: colorScheme.background.darken(3),
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: Colors.black.brighten(6),
      ),
      scaffoldBackgroundColor: Colors.black,
      toggleableActiveColor: colorScheme.primary,
      snackBarTheme: origin.snackBarTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        backgroundColor: colorScheme.primaryContainer,
        contentTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
      listTileTheme: origin.listTileTheme.copyWith(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22),
      ),
    );
  }

  static const defaultAccent = Color.fromARGB(255, 149, 30, 229);

  static final defaultLightScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.light,
  );

  static final defaultDarkScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.dark,
  );
}
