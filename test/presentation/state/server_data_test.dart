import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/fake_data.dart';
import '../../utils/hive.dart';
import '../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, ServerData> mapDefaultServers() {
    return Map.fromEntries(
      getDefaultServerData().map(
        (it) => MapEntry(it.key, it),
      ),
    );
  }

  group('server data', () {
    final ref = ProviderContainer(overrides: [
      defaultServersProvider.overrideWithValue(mapDefaultServers()),
    ]);
    final listener = FakePodListener<Iterable<ServerData>>();

    notifier() => ref.read(serverDataStateProvider.notifier);
    state() => ref.read(serverDataStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await ServerLocalSource.prepare();
      await SettingLocalSource.prepare();
      await notifier().populate();

      ref.listen(
        serverDataStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      ref.dispose();
      await destroyTestHive();
    });

    test('get', () async {
      expect(state().getById('Yandere').homepage, 'https://yande.re');
      expect(state().getById('deez'), state().first);
      expect(state().getById('deez', or: ServerData.empty), ServerData.empty);
    });

    test('add', () async {
      final foo = state()
          .getById('Konachan')
          .copyWith(id: 'FooBooru', homepage: 'https://foobooru.id');
      await notifier().add(foo);

      expect(state().getById('FooBooru').homepage, 'https://foobooru.id');
    });

    test('edit', () async {
      final orig = state().getById('Yandere');
      await notifier().edit(orig, orig.copyWith(alias: 'Yande.re'));

      expect(state().getById('Yandere').name, 'Yande.re');
    });

    test('remove', () async {
      final server = state().getById('Yandere');
      await notifier().remove(server);

      expect(
        state().getById('Yandere', or: ServerData.empty),
        ServerData.empty,
      );
    });

    test('reset', () async {
      await notifier().reset();

      expect(state().getById('Yandere').name, 'Yandere');
    });
  });
}
