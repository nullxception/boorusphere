import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/entity/ui_setting.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_setting_state.g.dart';

@riverpod
class UiSettingState extends _$UiSettingState {
  late SettingRepo _repo;

  @override
  UiSetting build() {
    _repo = ref.read(settingRepoProvider);
    return UiSetting(
      blur: _repo.get(Setting.uiBlur, or: true),
      grid: _repo.get(Setting.uiTimelineGrid, or: 1),
      locale: localeFromStr(_repo.get(Setting.uiLanguage, or: '')),
      themeMode: ThemeMode
          .values[_repo.get(Setting.uiThemeMode, or: ThemeMode.system.index)],
      midnightMode: _repo.get(Setting.uiMidnightMode, or: false),
      imeIncognito: _repo.get(Setting.imeIncognito, or: false),
    );
  }

  Future<int> cycleGrid() async {
    state = state.copyWith(grid: state.grid < 2 ? state.grid + 1 : 0);
    await _repo.put(Setting.uiTimelineGrid, state.grid);
    return state.grid;
  }

  Future<bool> showBlur(bool value) async {
    state = state.copyWith(blur: value);
    await _repo.put(Setting.uiBlur, value);
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
    await _repo.put(Setting.uiLanguage, locale == null ? '' : locale.name);
    return state.locale;
  }

  Future<ThemeMode> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.put(Setting.uiThemeMode, mode.index);
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
    await _repo.put(Setting.uiMidnightMode, value);
    return state.midnightMode;
  }

  Future<bool> setImeIncognito(bool value) async {
    state = state.copyWith(imeIncognito: value);
    await _repo.put(Setting.imeIncognito, value);
    return state.imeIncognito;
  }
}
