import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';

enum AppThemeVariant {
  light,
  dark,
  darker;
}

mixin AppTheme {
  static const idAccent = Color.fromARGB(255, 149, 30, 229);

  static final lightColorsDefault =
      ColorScheme.fromSeed(seedColor: AppTheme.idAccent);

  static final darkColorsDefault = ColorScheme.fromSeed(
      seedColor: AppTheme.idAccent, brightness: Brightness.dark);

  static ThemeData schemeFrom(ColorScheme? scheme, AppThemeVariant variant) {
    final colors = scheme?.harmonized();
    switch (variant) {
      case AppThemeVariant.dark:
        return AppTheme.dark(colors ?? darkColorsDefault);
      case AppThemeVariant.darker:
        return AppTheme.darker(colors ?? darkColorsDefault);
      default:
        return AppTheme.light(colors ?? lightColorsDefault);
    }
  }

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
