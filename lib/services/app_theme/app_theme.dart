import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme_data.dart';

final appThemeProvider = Provider((_) => AppThemeService());

enum AppThemeVariant {
  light,
  dark,
  darker;
}

class AppThemeService {
  late AppThemeData _data = AppThemeData.harmonize();

  AppThemeData get data => _data;

  void overrideWith({ColorScheme? light, ColorScheme? dark}) {
    _data = AppThemeData.harmonize(light: light, dark: dark);
  }

  static const idAccent = Color.fromARGB(255, 149, 30, 229);

  static final lightColorsDefault =
      ColorScheme.fromSeed(seedColor: AppThemeService.idAccent);

  static final darkColorsDefault = ColorScheme.fromSeed(
      seedColor: AppThemeService.idAccent, brightness: Brightness.dark);
}
