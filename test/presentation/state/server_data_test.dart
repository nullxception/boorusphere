import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/server/user_server_repo.dart';
import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/fake_data.dart';
import '../../utils/hive.dart';
import '../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, Server> mapDefaultServers() {
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
    final listener = FakePodListener<Iterable<Server>>();

    notifier() => ref.read(serverStateProvider.notifier);
    state() => ref.read(serverStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await UserServerRepo.prepare();
      await UserSettingsRepo.prepare();
      await notifier().populate();

      ref.listen(
        serverStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      await destroyTestHive();
      ref.dispose();
    });

    test('get', () async {
      expect(state().getById('Yandere').homepage, 'https://yande.re');
      expect(state().getById('deez'), state().first);
      expect(state().getById('deez', or: Server.empty), Server.empty);
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
        state().getById('Yandere', or: Server.empty),
        Server.empty,
      );
    });

    test('removeAll', () async {
      Future<void> removeAll() async {
        for (var server in state()) {
          await notifier().remove(server);
        }
      }

      expect(
        removeAll,
        throwsA(
          isA<Exception>()
              .having((e) => e.toString(), 'desc', contains('Last server')),
        ),
      );
    });

    test('reset', () async {
      await notifier().reset();

      expect(state().getById('Yandere').name, 'Yandere');
    });
  });
}
