import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme_data.dart';

class AppTheme {
  late AppThemeData _data = AppThemeData.harmonize();

  AppThemeData get data => _data;

  void overrideWith({ColorScheme? light, ColorScheme? dark}) {
    _data = AppThemeData.harmonize(light: light, dark: dark);
  }

  static const idAccent = Color.fromARGB(255, 149, 30, 229);

  static final lightColorsDefault =
      ColorScheme.fromSeed(seedColor: AppTheme.idAccent);

  static final darkColorsDefault = ColorScheme.fromSeed(
      seedColor: AppTheme.idAccent, brightness: Brightness.dark);

  static SystemUiOverlayStyle systemUiOverlayStyleof(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;
}
