import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/ui/blur.dart';
import 'package:boorusphere/presentation/provider/settings/ui/grid.dart';
import 'package:boorusphere/presentation/provider/settings/ui/language.dart';
import 'package:boorusphere/presentation/provider/settings/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UiSettingsProvider {
  static final grid = StateNotifierProvider<GridSettingNotifier, int>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.uiTimelineGrid, or: 1);
    return GridSettingNotifier(saved, repo);
  });

  static final lang =
      StateNotifierProvider<LanguageSettingNotifier, AppLocale?>((ref) {
    final repo = ref.read(settingRepoProvider);
    final savedCode = repo.get(Setting.uiLanguage, or: '');
    final saved = LanguageSettingNotifier.fromString(savedCode);
    return LanguageSettingNotifier(saved, repo);
  });

  static final theme =
      StateNotifierProvider<ThemeModeSettingNotifier, ThemeMode>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.uiThemeMode, or: ThemeMode.system.index);
    return ThemeModeSettingNotifier(ThemeMode.values[saved], repo);
  });

  static final darkerTheme =
      StateNotifierProvider<DarkerThemeSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.uiMidnightMode, or: false);
    return DarkerThemeSettingNotifier(saved, repo);
  });

  static final blur = StateNotifierProvider<UiBlurSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.uiBlur, or: false);
    return UiBlurSettingNotifier(saved, repo);
  });
}
