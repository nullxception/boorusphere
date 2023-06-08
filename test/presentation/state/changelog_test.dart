import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/changelog/changelog_repo_impl.dart';
import 'package:boorusphere/data/repository/changelog/entity/changelog_data.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/changelog_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../utils/riverpod.dart';
import 'app_version_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('changelog', () {
    test('assets', () async {
      final listener = FakePodListener<AsyncValue<List<ChangelogData>>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepoImpl()),
      ]);

      final logProvider = changelogStateProvider(ChangelogType.assets, null);
      ref.listen(logProvider, listener.call, fireImmediately: true);

      addTearDown(ref.dispose);

      await ref.read(logProvider.future);
      expect(
        ref.read(logProvider).value,
        isA<List<ChangelogData>>()
            .having((it) => it.first.version, 'version', isA<AppVersion>()),
      );
    });

    test('git', () async {
      final listener = FakePodListener<AsyncValue<List<ChangelogData>>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepoImpl()),
      ]);

      final adapter = DioAdapter(dio: ref.read(dioProvider));
      adapter.onGet(ChangelogRepoImpl.url, (server) => server.reply(200, '''
## 999.9.9
* Fix deez nuts
'''));
      final logProvider = changelogStateProvider(
          ChangelogType.git, AppVersion.fromString('999.9.9'));
      ref.listen(logProvider, listener.call, fireImmediately: true);

      addTearDown(ref.dispose);

      await ref.read(logProvider.future);
      expect(
        ref.read(logProvider).value,
        isA<List<ChangelogData>>().having((it) => it.first.version, 'version',
            AppVersion.fromString('999.9.9')),
      );
    });

    test('git but no response', () async {
      final listener = FakePodListener<AsyncValue<List<ChangelogData>>>();
      final ref = ProviderContainer(overrides: [
        envRepoProvider.overrideWithValue(FakeEnvRepoImpl()),
      ]);

      final adapter = DioAdapter(dio: ref.read(dioProvider));
      adapter.onGet(ChangelogRepoImpl.url, (server) => server.reply(200, ''));
      final logProvider = changelogStateProvider(
          ChangelogType.git, AppVersion.fromString('9.9.9'));
      ref.listen(logProvider, listener.call, fireImmediately: true);

      addTearDown(ref.dispose);

      await ref.read(logProvider.future);
      expect(ref.read(logProvider).value?.first.version, AppVersion.zero);
    });
  });
}
