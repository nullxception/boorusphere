import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  Brightness get brightness => theme.brightness;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkThemed => brightness == Brightness.dark;
  bool get isLightThemed => brightness == Brightness.light;

  NavigatorState get navigator => Navigator.of(this);
}
