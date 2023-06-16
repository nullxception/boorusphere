import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/hive.dart';
import '../../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServerSetting', () {
    final ref = ProviderContainer();
    final hiveContainer = HiveTestContainer();

    setUpAll(() async {
      await UserSettingsRepo.prepare();
      ref.setupTestFor(serverSettingStateProvider);
    });

    tearDownAll(() async {
      await hiveContainer.dispose();
      ref.dispose();
    });

    test('lastActiveId', () async {
      await ref
          .read(serverSettingStateProvider.notifier)
          .setLastActiveId('TestBooru');

      expect(
        ref.read(serverSettingStateProvider).lastActiveId,
        'TestBooru',
      );
    });

    test('postLimit', () async {
      await ref.read(serverSettingStateProvider.notifier).setPostLimit(90);

      expect(
        ref.read(serverSettingStateProvider).postLimit,
        90,
      );
    });

    test('searchRating', () async {
      await ref
          .read(serverSettingStateProvider.notifier)
          .setRating(BooruRating.fromName('explicit'));

      expect(
        ref.read(serverSettingStateProvider).searchRating,
        BooruRating.explicit,
      );
    });
  });
}
