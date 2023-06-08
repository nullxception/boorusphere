import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_setting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/hive.dart';
import '../../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DownloadSetting', () {
    final ref = ProviderContainer();
    final listener = FakePodListener<DownloadSetting>();

    notifier() => ref.read(downloadSettingStateProvider.notifier);
    state() => ref.read(downloadSettingStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await UserSettingsRepo.prepare();
      ref.listen<DownloadSetting>(
        downloadSettingStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      ref.dispose();
      await destroyTestHive();
    });

    test('groupByServer', () async {
      await notifier().setGroupByServer(true);

      expect(state().groupByServer, true);
    });

    test('quality', () async {
      await notifier().setQuality(DownloadQuality.fromName('original'));

      expect(state().quality, DownloadQuality.original);
    });
  });
}
