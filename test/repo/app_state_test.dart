import 'package:boorusphere/data/repository/app_state/current_app_state_repo.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utils/hive.dart';
import '../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ref = ProviderContainer();
  final hiveContainer = HiveTestContainer();

  setUpAll(() async {
    await CurrentAppStateRepo.prepare();
    ref.setupTestFor(appStateRepoProvider);
  });

  tearDownAll(() async {
    await hiveContainer.dispose();
    ref.dispose();
  });

  test('initial version', () async {
    expect(ref.read(appStateRepoProvider).version, AppVersion.zero);
  });

  test('storing version', () async {
    final fakeVersion = AppVersion.fromString('69.0.0');
    await ref.read(appStateRepoProvider).storeVersion(fakeVersion);
    expect(ref.read(appStateRepoProvider).version, fakeVersion);
  });
}
