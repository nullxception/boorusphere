import 'package:boorusphere/entity/favorite_post.dart';
import 'package:boorusphere/entity/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesDataSource, Map<String, FavoritePost>>(
        (ref) {
  final storage = FavoritesDataSource._storage;
  return FavoritesDataSource(ref, Map.from(storage.toMap()));
});

class FavoritesDataSource extends StateNotifier<Map<String, FavoritePost>> {
  FavoritesDataSource(this.ref, super.state);

  final Ref ref;

  void _refresh() {
    state = Map.from(_storage.toMap());
  }

  Future<void> clear() async {
    await _storage.clear();
    _refresh();
  }

  Future<void> delete(Post post) async {
    final fav = FavoritePost(post: post);
    await _storage.delete(fav.key);
    _refresh();
  }

  bool checkExists(Post post) {
    return state.values.map((e) => e.post).contains(post);
  }

  Future<void> save(Post post) async {
    if (checkExists(post)) return;

    final fav = FavoritePost(
      post: post,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _storage.put(fav.key, fav);
    _refresh();
  }

  static Box get _storage => Hive.box('favorites');
}
