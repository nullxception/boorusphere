import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeSettingNotifier extends StateNotifier<ThemeMode> {
  ThemeModeSettingNotifier(super.state, this.repo);
  final SettingRepo repo;

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

class DarkerThemeSettingNotifier extends StateNotifier<bool> {
  DarkerThemeSettingNotifier(super.state, this.repo);
  final SettingRepo repo;

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.uiMidnightMode, value);
  }
}
