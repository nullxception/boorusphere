import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
class ThemeModeSettingState extends _$ThemeModeSettingState {
  late SettingRepo repo;

  @override
  ThemeMode build() {
    repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.uiThemeMode, or: ThemeMode.system.index);
    return ThemeMode.values[saved];
  }

  Future<void> update(ThemeMode mode) async {
    state = mode;
    await repo.put(Setting.uiThemeMode, mode.index);
  }

  Future<ThemeMode> cycle() async {
    switch (state) {
      case ThemeMode.dark:
        await update(ThemeMode.light);
        break;
      case ThemeMode.light:
        await update(ThemeMode.system);
        break;
      default:
        await update(ThemeMode.dark);
        break;
    }
    return state;
  }
}

@riverpod
class MidnightModeSettingState extends _$MidnightModeSettingState {
  late SettingRepo repo;

  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.uiMidnightMode, or: false);
  }

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.uiMidnightMode, value);
  }
}
