import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/hive.dart';
import '../../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentSetting', () {
    final ref = ProviderContainer();
    final hiveContainer = HiveTestContainer();

    notifier() => ref.read(contentSettingStateProvider.notifier);
    state() => ref.read(contentSettingStateProvider);

    setUpAll(() async {
      await UserSettingsRepo.prepare();
      ref.setupTestFor(contentSettingStateProvider);
    });

    tearDownAll(() async {
      await hiveContainer.dispose();
      ref.dispose();
    });

    test('blurExplicit', () async {
      await notifier().setBlurExplicitPost(false);

      expect(state().blurExplicit, false);
    });

    test('blurTimelineOnly', () async {
      await notifier().setBlurTimelineOnly(true);

      expect(state().blurTimelineOnly, true);
    });

    test('loadOriginal', () async {
      await notifier().setLoadOriginalPost(true);

      expect(state().loadOriginal, true);
    });

    test('videoMuted', () async {
      final initial = state().videoMuted;
      await notifier().toggleVideoPlayerMute();

      expect(state().videoMuted, !initial);
    });
  });
}
