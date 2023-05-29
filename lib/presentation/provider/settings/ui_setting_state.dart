import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/entity/ui_setting.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_setting_state.g.dart';

@riverpod
class UiSettingState extends _$UiSettingState {
  @override
  UiSetting build() {
    final repo = ref.read(settingRepoProvider);
    return UiSetting(
      grid: repo.get(Setting.uiTimelineGrid, or: 1),
      locale: localeFromStr(repo.get(Setting.uiLanguage, or: '')),
      themeMode: ThemeMode
          .values[repo.get(Setting.uiThemeMode, or: ThemeMode.system.index)],
      midnightMode: repo.get(Setting.uiMidnightMode, or: false),
      imeIncognito: repo.get(Setting.imeIncognito, or: false),
    );
  }

  Future<int> cycleGrid() async {
    state = state.copyWith(grid: state.grid < 2 ? state.grid + 1 : 0);
    final repo = ref.read(settingRepoProvider);

    await repo.put(Setting.uiTimelineGrid, state.grid);
    return state.grid;
  }

  AppLocale? localeFromStr(String name) {
    try {
      return AppLocale.values.firstWhere((it) => it.name == name);
    } on StateError {
      return null;
    }
  }

  Future<AppLocale?> setLocale(AppLocale? locale) async {
    final repo = ref.read(settingRepoProvider);
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
    final repo = ref.read(settingRepoProvider);

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
    final repo = ref.read(settingRepoProvider);
    state = state.copyWith(midnightMode: value);
    await repo.put(Setting.uiMidnightMode, value);
    return state.midnightMode;
  }

  Future<bool> setImeIncognito(bool value) async {
    final repo = ref.read(settingRepoProvider);
    state = state.copyWith(imeIncognito: value);
    await repo.put(Setting.imeIncognito, value);
    return state.imeIncognito;
  }
}
