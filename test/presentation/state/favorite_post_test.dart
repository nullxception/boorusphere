import 'package:boorusphere/data/repository/favorite_post/user_favorite_post_repo.dart';
import 'package:boorusphere/presentation/provider/favorite_post_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/fake_data.dart';
import '../../utils/hive.dart';
import '../../utils/riverpod.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('favorite post', () {
    final posts = getSamplePosts();
    final ref = ProviderContainer();
    final hiveContainer = HiveTestContainer();

    notifier() => ref.read(favoritePostStateProvider.notifier);
    state() => ref.read(favoritePostStateProvider);

    setUpAll(() async {
      await UserFavoritePostRepo.prepare();
      ref.setupTestFor(favoritePostStateProvider);
    });

    tearDownAll(() async {
      await hiveContainer.dispose();
      ref.dispose();
    });

    test('push all', () async {
      for (var element in posts) {
        await notifier().save(element);
      }
      expect(state().length, 3);
    });

    test('remove last', () async {
      await notifier().remove(posts.last);
      expect(state().length, 2);
    });

    test('cleanup', () async {
      await notifier().clear();
      expect(state().length, 0);
    });
  });
}
