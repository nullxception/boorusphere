import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';

class BlockedTagsRepoImpl implements BlockedTagsRepo {
  BlockedTagsRepoImpl({required this.localSource});

  final BlockedTagsLocalSource localSource;

  @override
  Map<int, String> get() => localSource.get();

  @override
  Future<void> delete(key) => localSource.delete(key);

  @override
  Future<void> push(String value) => localSource.push(value);
}
