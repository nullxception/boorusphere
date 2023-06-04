import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
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

class FakeEnvRepoImpl extends Mock implements EnvRepo {
  @override
  AppVersion get appVersion => AppVersion.fromString('1.1.1');
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('app version', () {
    test('get', () async {
      final listener = FakePodListener<AsyncValue<AppVersions>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepoImpl()),
      ]);

      final dioAdapter = DioAdapter(dio: ref.read(dioProvider));
      dioAdapter.onGet(
          VersionNetworkSource.pubspecUrl, (server) => server.reply(200, '''
# comments
version: 9.9.9+99

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
      expect(
        ref.read(appVersionsStateProvider).value?.current,
        AppVersion.fromString('1.1.1'),
      );
      expect(
        ref.read(appVersionsStateProvider).value?.latest,
        AppVersion.fromString('9.9.9'),
      );
    });

    test('empty response', () async {
      final listener = FakePodListener<AsyncValue<AppVersions>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepoImpl()),
      ]);

      final dioAdapter = DioAdapter(dio: ref.read(dioProvider));
      dioAdapter.onGet(
        VersionNetworkSource.pubspecUrl,
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
