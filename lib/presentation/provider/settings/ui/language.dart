import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSettingNotifier extends StateNotifier<AppLocale?> {
  LanguageSettingNotifier(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(AppLocale? locale) async {
    state = locale;
    if (locale == null) {
      LocaleSettings.useDeviceLocale();
    } else {
      LocaleSettings.setLocale(locale);
    }
    await repo.put(Setting.uiLanguage, locale == null ? '' : locale.name);
  }

  static AppLocale? fromString(String name) {
    try {
      return AppLocale.values.firstWhere((it) => it.name == name);
    } on StateError {
      return null;
    }
  }
}
