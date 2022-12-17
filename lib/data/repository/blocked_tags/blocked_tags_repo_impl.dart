import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';

class BlockedTagsRepoImpl implements BlockedTagsRepo {
  BlockedTagsRepoImpl({required this.localSource});

  final BlockedTagsLocalSource localSource;

  @override
  Map<int, BooruTag> get() => localSource.get();

  @override
  Future<void> delete(key) => localSource.delete(key);

  @override
  Future<void> push(BooruTag value) => localSource.push(value);
}
