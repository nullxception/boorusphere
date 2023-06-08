import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';

abstract interface class FavoritePostRepo {
  Iterable<Post> get();
  Future<void> clear();
  Future<void> remove(Post post);
  Future<void> save(Post post);
  Future<void> import(String src);
  Future<BackupItem> export();
}
