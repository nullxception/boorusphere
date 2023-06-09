import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/search_history/user_search_history.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/fake_data.dart';
import '../../utils/hive.dart';
import '../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('search history', () {
    final servers = getDefaultServerData();
    final ref = ProviderContainer();
    final listener = FakePodListener<Map<int, SearchHistory>>();

    notifier() => ref.read(searchHistoryStateProvider.notifier);
    state() => ref.read(searchHistoryStateProvider);

    setUpAll(() async {
      initializeTestHive();
      await UserSearchHistoryRepo.prepare();
      ref.listen(
        searchHistoryStateProvider,
        listener.call,
        fireImmediately: true,
      );
    });

    tearDownAll(() async {
      await destroyTestHive();
      ref.dispose();
    });

    test('push', () async {
      final tags = ['foo', 'bar', 'baz'];
      for (var tag in tags) {
        await notifier().save(tag, servers.first);
      }
      expect(state().length, 3);
    });

    test('filter', () {
      expect(ref.read(FilterHistoryProvider('o')).values.first.query, 'foo');
      expect(ref.read(FilterHistoryProvider('r')).values.first.query, 'bar');
      expect(ref.read(FilterHistoryProvider('z')).values.first.query, 'baz');
      expect(ref.read(FilterHistoryProvider('m')).length, 0);
    });

    test('remove last', () async {
      await notifier().delete(state().keys.last);
      expect(state().length, 2);
    });

    test('cleanup', () async {
      await notifier().clear();
      expect(state().length, 0);
    });
  });
}
