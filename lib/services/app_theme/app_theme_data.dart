import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'app_theme.dart';

part 'app_theme_data.freezed.dart';

@freezed
class AppThemeData with _$AppThemeData {
  const factory AppThemeData({
    required ThemeData day,
    required ThemeData night,
    required ThemeData midnight,
  }) = _AppThemeData;
  const AppThemeData._();

  factory AppThemeData.harmonize({ColorScheme? light, ColorScheme? dark}) {
    return AppThemeData(
      day: _lightOf(light?.harmonized() ?? AppThemeService.lightColorsDefault),
      night: _nightOf(dark?.harmonized() ?? AppThemeService.darkColorsDefault),
      midnight:
          _midnightOf(dark?.harmonized() ?? AppThemeService.darkColorsDefault),
    );
  }

  static ThemeData _lightOf(ColorScheme seededScheme) {
    final origin = ThemeData.light();
    return origin.copyWith(
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
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: seededScheme.surface.shade(3),
      ),
      toggleableActiveColor: seededScheme.primary,
      snackBarTheme: origin.snackBarTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        backgroundColor: seededScheme.primaryContainer,
        contentTextStyle: TextStyle(color: seededScheme.onPrimaryContainer),
      ),
    );
  }

  static ThemeData _nightOf(ColorScheme seededScheme) {
    final origin = ThemeData.dark();
    return origin.copyWith(
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
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: seededScheme.surface.shade(40),
      ),
      toggleableActiveColor: seededScheme.primary,
      snackBarTheme: origin.snackBarTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        backgroundColor: seededScheme.primaryContainer,
        contentTextStyle: TextStyle(color: seededScheme.onPrimaryContainer),
      ),
    );
  }

  static ThemeData _midnightOf(ColorScheme seededScheme) {
    final origin = ThemeData.dark();
    return origin.copyWith(
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
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: Colors.black.brighten(6),
      ),
      scaffoldBackgroundColor: Colors.black,
      toggleableActiveColor: seededScheme.primary,
      snackBarTheme: origin.snackBarTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        backgroundColor: seededScheme.primaryContainer,
        contentTextStyle: TextStyle(color: seededScheme.onPrimaryContainer),
      ),
    );
  }
}
