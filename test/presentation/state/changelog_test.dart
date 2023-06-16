import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/changelog/entity/changelog_data.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/changelog_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/dio.dart';
import '../../utils/mocktail.dart';
import '../../utils/riverpod.dart';
import 'app_version_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMocktailFallbacks();

  group('changelog', () {
    test('assets', () async {
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);

      final logProvider = changelogStateProvider(ChangelogType.assets, null);
      ref.setupTestFor(logProvider);

      addTearDown(ref.dispose);

      await ref.read(logProvider.future);
      expect(
        ref.read(logProvider).value,
        isA<List<ChangelogData>>()
            .having((it) => it.first.version, 'version', isA<AppVersion>()),
      );
    });

    test('git', () async {
      final logProvider = changelogStateProvider(
        ChangelogType.git,
        AppVersion.fromString('999.9.9'),
      );

      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);

      ref.setupTestFor(dioProvider);
      ref.setupTestFor(logProvider);

      addTearDown(ref.dispose);

      final adapter = DioAdapterMock(ref.read(dioProvider));
      when(() => adapter.fetch(any(), any(), any())).thenAnswer(
          (invocation) async =>
              ResponseBody.fromString('\n## 999.9.9\n* Fix deez nuts\n', 200));

      await ref.read(logProvider.future);

      expect(
        ref.read(logProvider).value,
        isA<List<ChangelogData>>().having((it) => it.first.version, 'version',
            AppVersion.fromString('999.9.9')),
      );
    });

    test('git but no response', () async {
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepo()),
      ]);
      final logProvider = changelogStateProvider(
          ChangelogType.git, AppVersion.fromString('9.9.9'));

      ref.setupTestFor(dioProvider);
      ref.setupTestFor(logProvider);

      final adapter = DioAdapterMock(ref.read(dioProvider));
      when(() => adapter.fetch(any(), any(), any()))
          .thenAnswer((invocation) async => ResponseBody.fromString('', 200));

      addTearDown(ref.dispose);

      await ref.read(logProvider.future);
      expect(ref.read(logProvider).value?.first.version, AppVersion.zero);
    });
  });
}
