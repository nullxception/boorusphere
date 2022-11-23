import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_setting.freezed.dart';

@freezed
class UiSetting with _$UiSetting {
  const factory UiSetting({
    @Default(false) bool blur,
    @Default(1) int grid,
    AppLocale? locale,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool midnightMode,
  }) = _UiSetting;
}
