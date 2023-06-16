import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/presentation/provider/app_versions/app_versions_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/dio.dart';
import '../../utils/mocktail.dart';
import '../../utils/riverpod.dart';

class FakeEnvRepo extends Mock implements EnvRepo {
  @override
  AppVersion get appVersion => AppVersion.fromString('1.1.1');
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMocktailFallbacks();

  group('app version', () {
    test('get', () async {
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);

      addTearDown(ref.dispose);

      ref.setupTestFor(dioProvider);
      ref.setupTestFor(appVersionsStateProvider);

      const edgeVersion = '9.9.9';
      final adapter = DioAdapterMock(ref.read(dioProvider));
      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
          (invocation) async => ResponseBody.fromString(
              '\n# comments\nversion: $edgeVersion+99\n', 200));

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
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);

      ref.setupTestFor(dioProvider);
      ref.setupTestFor(appVersionsStateProvider);

      final adapter = DioAdapterMock(ref.read(dioProvider));
      when(() => adapter.fetch(any(), any(), any()))
          .thenAnswer((invocation) async => ResponseBody.fromString('', 200));

      addTearDown(ref.dispose);

      await ref.read(appVersionsStateProvider.future);
      expect(
        ref.read(appVersionsStateProvider).value?.latest,
        AppVersion.zero,
      );
    });
  });
}
