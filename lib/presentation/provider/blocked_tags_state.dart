import 'package:boorusphere/data/repository/blocked_tags/entity/booru_tag.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blocked_tags_state.g.dart';

@Riverpod(keepAlive: true)
class BlockedTagsState extends _$BlockedTagsState {
  @override
  Map<int, BooruTag> build() {
    final repo = ref.read(blockedTagsRepoProvider);
    return repo.get();
  }

  Future<void> delete(key) async {
    final repo = ref.read(blockedTagsRepoProvider);
    await repo.delete(key);
    state = repo.get();
  }

  Future<void> push({
    String serverId = '',
    required String tag,
  }) async {
    final repo = ref.read(blockedTagsRepoProvider);
    await repo.push(BooruTag(serverId: serverId, name: tag));
    state = repo.get();
  }

  Future<void> pushAll({
    String serverId = '',
    required List<String> tags,
  }) async {
    final repo = ref.read(blockedTagsRepoProvider);
    for (var tag in tags) {
      await repo.push(BooruTag(serverId: serverId, name: tag));
    }
    state = repo.get();
  }
}
