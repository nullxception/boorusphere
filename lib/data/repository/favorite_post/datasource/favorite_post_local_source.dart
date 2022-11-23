import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritePostLocalSource {
  FavoritePostLocalSource(this.box);

  final Box<FavoritePost> box;

  IList<Post> get() {
    return box.values.map((e) => e.post).toIList();
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> delete(Post post) async {
    final fav = FavoritePost(post: post);
    await box.delete(fav.key);
  }

  Future<void> save(Post post) async {
    final fav = FavoritePost(
      post: post,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await box.put(fav.key, fav);
  }

  static const String key = 'favorites';
  static Future<void> prepare() => Hive.openBox<FavoritePost>(key);
}
