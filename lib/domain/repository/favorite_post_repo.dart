import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

abstract class FavoritePostRepo {
  IList<Post> get();
  Future<void> clear();
  Future<void> remove(Post post);
  Future<void> save(Post post);
}
