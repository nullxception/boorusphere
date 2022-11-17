import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_settings.freezed.dart';
part 'ui_settings.g.dart';

@freezed
class UiSettings with _$UiSettings {
  const factory UiSettings({
    @Default(false) bool blur,
    @Default(1) int grid,
    AppLocale? locale,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool midnightMode,
  }) = _UiSettings;
}

@riverpod
class UiSettingState extends _$UiSettingState {
  late SettingRepo repo;

  @override
  UiSettings build() {
    repo = ref.read(settingRepoProvider);
    return UiSettings(
      blur: repo.get(Setting.uiBlur, or: false),
      grid: repo.get(Setting.uiTimelineGrid, or: 1),
      locale: localeFromStr(repo.get(Setting.uiLanguage, or: '')),
      themeMode: ThemeMode
          .values[repo.get(Setting.uiThemeMode, or: ThemeMode.system.index)],
      midnightMode: repo.get(Setting.uiMidnightMode, or: false),
    );
  }

  Future<int> cycleGrid() async {
    state = state.copyWith(grid: state.grid < 2 ? state.grid + 1 : 0);
    await repo.put(Setting.uiTimelineGrid, state.grid);
    return state.grid;
  }

  Future<bool> showBlur(bool value) async {
    state = state.copyWith(blur: value);
    await repo.put(Setting.uiBlur, value);
    return state.blur;
  }

  AppLocale? localeFromStr(String name) {
    try {
      return AppLocale.values.firstWhere((it) => it.name == name);
    } on StateError {
      return null;
    }
  }

  Future<AppLocale?> setLocale(AppLocale? locale) async {
    state = state.copyWith(locale: locale);
    if (locale == null) {
      LocaleSettings.useDeviceLocale();
    } else {
      LocaleSettings.setLocale(locale);
    }
    await repo.put(Setting.uiLanguage, locale == null ? '' : locale.name);
    return state.locale;
  }

  Future<ThemeMode> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await repo.put(Setting.uiThemeMode, mode.index);
    return state.themeMode;
  }

  Future<ThemeMode> cycleThemeMode() async {
    switch (state.themeMode) {
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.system);
        break;
      default:
        await setThemeMode(ThemeMode.dark);
        break;
    }
    return state.themeMode;
  }

  Future<bool> setMidnightMode(bool value) async {
    state = state.copyWith(midnightMode: value);
    await repo.put(Setting.uiMidnightMode, value);
    return state.midnightMode;
  }
}
