import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/domain/provider/favorite_post.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritePostProvider =
    StateNotifierProvider<FavoritePostState, Map<String, FavoritePost>>((ref) {
  final repo = ref.watch(favoritePostRepoProvider);
  return FavoritePostState(repo.get(), repo);
});

class FavoritePostState extends StateNotifier<Map<String, FavoritePost>> {
  FavoritePostState(super.state, this.repo);

  final FavoritePostRepo repo;

  Future<void> clear() async {
    await repo.clear();
    state = repo.get();
  }

  Future<void> delete(Post post) async {
    await repo.delete(post);
    state = repo.get();
  }

  bool checkExists(Post post) {
    return state.values.map((e) => e.post).contains(post);
  }

  Future<void> save(Post post) async {
    if (checkExists(post)) return;
    await repo.save(post);
    state = repo.get();
  }
}
