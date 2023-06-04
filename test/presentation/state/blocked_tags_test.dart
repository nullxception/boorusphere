import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/hive.dart';
import '../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('blocked tags', () {
    const serverId = 'TestBooru';
    final ref = ProviderContainer();
    final listener = FakePodListener<Map<int?, BooruTag>>();

    notifier() => ref.read(blockedTagsStateProvider.notifier);
    state() => ref.read(blockedTagsStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await BlockedTagsLocalSource.prepare();
      ref.listen(
        blockedTagsStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      ref.dispose();
      await destroyTestHive();
    });

    test('push', () async {
      await notifier().push(serverId: serverId, tag: 'foo');

      expect(
        state().values.any((it) => it.name == 'foo'),
        true,
      );
    });

    test('pushall', () async {
      await notifier().pushAll(serverId: serverId, tags: ['foo', 'bar']);

      expect(
        state().values.any((it) => it.name == 'bar'),
        true,
      );
    });

    test('delete', () async {
      for (var key in state().keys) {
        await notifier().delete(key);
      }

      expect(state().length, 0);
    });
  });
}
