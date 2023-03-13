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
    final harmonized = scheme?.harmonized() ?? defScheme;
    final colorScheme = harmonized.copyWith(
      background: harmonized.surface.shade(isDark ? 30 : 3),
      outlineVariant: harmonized.outlineVariant.withOpacity(0.3),
    );
    final origin = isDark ? ThemeData.dark() : ThemeData.light();
    return origin.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onSurface,
      ),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      dialogBackgroundColor: colorScheme.background,
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: colorScheme.surface,
      ),
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
        iconColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  ThemeData _createThemeDataMidnight(ColorScheme? scheme) {
    final origin = _createThemeData(scheme, Brightness.dark);
    return origin.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: origin.colorScheme.onSurface,
      ),
      primaryColor: Colors.black,
      canvasColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      colorScheme: origin.colorScheme.copyWith(
        brightness: Brightness.dark,
        background: Colors.black,
        surface: origin.colorScheme.background,
      ),
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
