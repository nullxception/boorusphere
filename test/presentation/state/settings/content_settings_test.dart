import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/entity/content_setting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/hive.dart';
import '../../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentSetting', () {
    final ref = ProviderContainer();
    final listener = FakePodListener<ContentSetting>();

    notifier() => ref.read(contentSettingStateProvider.notifier);
    state() => ref.read(contentSettingStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await SettingLocalSource.prepare();
      ref.listen<ContentSetting>(
        contentSettingStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      ref.dispose();
      await destroyTestHive();
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
