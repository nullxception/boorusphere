import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tinycolor2/tinycolor2.dart';

part 'app_theme.g.dart';

@riverpod
AppThemeDataNotifier appThemeData(AppThemeDataRef ref) {
  return AppThemeDataNotifier();
}

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

class AppThemeDataNotifier {
  late AppThemeData _data = _createAppThemeData();

  AppThemeData get data => _data;

  AppThemeData fillWith({ColorScheme? light, ColorScheme? dark}) {
    _data = _createAppThemeData(light: light, dark: dark);
    return _data;
  }

  AppThemeData _createAppThemeData({ColorScheme? light, ColorScheme? dark}) {
    return AppThemeData(
      day: _createThemeData(light, Brightness.light),
      night: _createThemeData(dark, Brightness.dark),
      midnight: _createThemeDataMidnight(dark),
    );
  }

  ThemeData _createThemeData(ColorScheme? scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final defScheme = isDark ? defDarkScheme : defLightScheme;
    final colorScheme = scheme?.harmonized() ?? defScheme;
    final origin = isDark ? ThemeData.dark() : ThemeData.light();
    return origin.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? colorScheme.surface.darken(2) : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: isDark
          ? colorScheme.surface.lighten(3)
          : colorScheme.surface.darken(2),
      scaffoldBackgroundColor:
          isDark ? colorScheme.surface.darken(2) : colorScheme.surface,
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: isDark
            ? colorScheme.surface.shade(40)
            : colorScheme.surface.shade(3),
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

  ThemeData _createThemeDataMidnight(ColorScheme? scheme) {
    final origin = _createThemeData(scheme, Brightness.dark);
    return origin.copyWith(
      colorScheme: origin.colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: origin.colorScheme.background,
        background: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: origin.colorScheme.onSurface,
        elevation: 0,
      ),
      primaryColor: Colors.black,
      backgroundColor: Colors.black,
      canvasColor: Colors.black,
      cardColor: origin.colorScheme.background.darken(3),
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }

  static const defaultAccent = Color.fromARGB(255, 149, 30, 229);

  static final defLightScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.light,
  );

  static final defDarkScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.dark,
  );
}
