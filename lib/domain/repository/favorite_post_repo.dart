import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';

abstract class FavoritePostRepo {
  Map<String, FavoritePost> get();
  Future<void> clear();
  Future<void> delete(Post post);
  Future<void> save(Post post);
}
