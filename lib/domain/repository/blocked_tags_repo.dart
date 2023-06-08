import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';

abstract interface class BlockedTagsRepo {
  Map<int, BooruTag> get();
  Future<void> delete(key);
  Future<void> push(BooruTag value);
  Future<void> import(String src);
  Future<BackupItem> export();
}
