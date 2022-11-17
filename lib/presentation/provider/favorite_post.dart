import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_post.g.dart';

@riverpod
class FavoritePostState extends _$FavoritePostState {
  late FavoritePostRepo repo;

  @override
  Map<String, FavoritePost> build() {
    final repo = ref.read(favoritePostRepoProvider);
    return repo.get();
  }

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
