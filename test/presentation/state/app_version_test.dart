import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/version/app_version_repo.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/presentation/provider/app_versions/app_versions_state.dart';
import 'package:boorusphere/presentation/provider/app_versions/entity/app_versions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/riverpod.dart';

class FakeEnvRepo extends Mock implements EnvRepo {
  @override
  AppVersion get appVersion => AppVersion.fromString('1.1.1');
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('app version', () {
    test('get', () async {
      final listener = FakePodListener<AsyncValue<AppVersions>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);

      const edgeVersion = '9.9.9';
      final dioAdapter = DioAdapter(dio: ref.read(dioProvider));
      dioAdapter.onGet(
          AppVersionRepo.pubspecUrl, (server) => server.reply(200, '''
# comments
version: $edgeVersion+99

'''));

      ref.listen(
        appVersionsStateProvider,
        listener.call,
        fireImmediately: true,
      );

      addTearDown(() async {
        ref.dispose();
      });

      await ref.read(appVersionsStateProvider.future);
      final versions = ref.read(appVersionsStateProvider).value;
      expect(versions?.current, AppVersion.fromString('1.1.1'));
      expect(versions?.latest, AppVersion.fromString(edgeVersion));
      expect(
        versions?.latest.apkUrl,
        contains('download/$edgeVersion/boorusphere-$edgeVersion'),
      );
    });

    test('isNewerThan', () {
      final first = AppVersion.fromString('9.9.1');
      final second = AppVersion.fromString('9.9.2');
      expect(second.isNewerThan(first), true);
      expect(first.isNewerThan(second), false);
      expect(first.isNewerThan(first), false);
    });

    test('empty response', () async {
      final listener = FakePodListener<AsyncValue<AppVersions>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);

      final dioAdapter = DioAdapter(dio: ref.read(dioProvider));
      dioAdapter.onGet(
        AppVersionRepo.pubspecUrl,
        (server) => server.reply(200, ''),
      );

      ref.listen(
        appVersionsStateProvider,
        listener.call,
        fireImmediately: true,
      );

      addTearDown(() async {
        ref.dispose();
      });

      await ref.read(appVersionsStateProvider.future);
      expect(
        ref.read(appVersionsStateProvider).value?.latest,
        AppVersion.zero,
      );
    });
  });
}
