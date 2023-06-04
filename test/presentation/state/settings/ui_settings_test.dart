import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/settings/entity/ui_setting.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/hive.dart';
import '../../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UiSetting', () {
    final ref = ProviderContainer();
    final listener = FakePodListener<UiSetting>();

    notifier() => ref.read(uiSettingStateProvider.notifier);
    state() => ref.read(uiSettingStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await SettingLocalSource.prepare();
      ref.listen<UiSetting>(
        uiSettingStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      ref.dispose();
      await destroyTestHive();
    });

    test('blur', () async {
      await notifier().showBlur(false);

      expect(state().blur, false);
    });

    test('grid', () async {
      final initial = state().grid;
      await notifier().cycleGrid();

      expect(state().grid, initial + 1);
    });

    test('locale', () async {
      await notifier().setLocale(AppLocale.idId);

      expect(state().locale, AppLocale.idId);
    });

    test('cycle themeMode', () async {
      await notifier().setThemeMode(ThemeMode.light);
      await notifier().cycleThemeMode();

      expect(state().themeMode, ThemeMode.system);
    });

    test('midnightMode', () async {
      await notifier().setMidnightMode(true);

      expect(state().midnightMode, true);
    });

    test('imeIncognito', () async {
      await notifier().setImeIncognito(true);

      expect(state().imeIncognito, true);
    });
  });
}
