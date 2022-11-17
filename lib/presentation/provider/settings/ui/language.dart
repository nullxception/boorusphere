import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language.g.dart';

@riverpod
class LanguageSettingState extends _$LanguageSettingState {
  late SettingRepo repo;
  @override
  AppLocale? build() {
    repo = ref.read(settingRepoProvider);
    final savedCode = repo.get(Setting.uiLanguage, or: '');
    return fromString(savedCode);
  }

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
