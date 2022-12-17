import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blocked_tags_state.g.dart';

@Riverpod(keepAlive: true)
class BlockedTagsState extends _$BlockedTagsState {
  late BlockedTagsRepo _repo;

  @override
  Map<int, BooruTag> build() {
    _repo = ref.read(blockedTagsRepoProvider);
    return _repo.get();
  }

  Future<void> delete(key) async {
    await _repo.delete(key);
    state = _repo.get();
  }

  Future<void> push({
    String serverId = '',
    required String tag,
  }) async {
    await _repo.push(BooruTag(serverId: serverId, name: tag));
    state = _repo.get();
  }

  Future<void> pushAll({
    String serverId = '',
    required List<String> tags,
  }) async {
    for (var tag in tags) {
      await _repo.push(BooruTag(serverId: serverId, name: tag));
    }
    state = _repo.get();
  }
}
