import 'package:boorusphere/data/entity/post.dart';
import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/domain/repository/favorite_post_repo.dart';

class FavoritePostRepoImpl implements FavoritePostRepo {
  FavoritePostRepoImpl({required this.localSource});

  final FavoritePostLocalSource localSource;

  @override
  Future<void> clear() => localSource.clear();

  @override
  Future<void> delete(Post post) => localSource.delete(post);

  @override
  Map<String, FavoritePost> get() => localSource.get();

  @override
  Future<void> save(Post post) => localSource.save(post);
}
