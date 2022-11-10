import 'package:boorusphere/domain/provider/blocked_tags.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedTagsStateProvider =
    StateNotifierProvider<BlockedTagsState, Map<int, String>>((ref) {
  final repo = ref.watch(blockedTagsRepoProvider);
  return BlockedTagsState(repo.get(), repo);
});

class BlockedTagsState extends StateNotifier<Map<int, String>> {
  BlockedTagsState(super.state, this.repo);

  final BlockedTagsRepo repo;

  Future<void> delete(key) async {
    await repo.delete(key);
    state = repo.get();
  }

  Future<void> push(String value) async {
    await repo.push(value);
    state = repo.get();
  }

  Future<void> pushAll(List<String> values) async {
    for (var tag in values) {
      await repo.push(tag);
    }
    state = repo.get();
  }
}
