import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_post_state.g.dart';

@riverpod
class FavoritePostState extends _$FavoritePostState {
  late FavoritePostRepo _repo;

  @override
  IList<Post> build() {
    _repo = ref.read(favoritePostRepoProvider);
    return _repo.get();
  }

  Future<void> clear() async {
    await _repo.clear();
    state = _repo.get();
  }

  Future<void> remove(Post post) async {
    await _repo.remove(post);
    state = _repo.get();
  }

  Future<void> save(Post post) async {
    if (state.contains(post)) return;
    await _repo.save(post);
    state = _repo.get();
  }
}
