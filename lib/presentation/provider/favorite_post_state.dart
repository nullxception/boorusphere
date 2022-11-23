import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_post_state.g.dart';

@riverpod
class FavoritePostState extends _$FavoritePostState {
  late FavoritePostRepo repo;

  @override
  IList<Post> build() {
    repo = ref.read(favoritePostRepoProvider);
    return repo.get();
  }

  Future<void> clear() async {
    await repo.clear();
    state = repo.get();
  }

  Future<void> remove(Post post) async {
    await repo.remove(post);
    state = repo.get();
  }

  Future<void> save(Post post) async {
    if (state.contains(post)) return;
    await repo.save(post);
    state = repo.get();
  }
}
