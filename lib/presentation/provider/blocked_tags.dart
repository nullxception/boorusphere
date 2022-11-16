import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedTagsProvider =
    StateNotifierProvider<BlockedTagsNotifier, Map<int, String>>((ref) {
  final repo = ref.read(blockedTagsRepoProvider);
  return BlockedTagsNotifier(repo.get(), repo);
});

class BlockedTagsNotifier extends StateNotifier<Map<int, String>> {
  BlockedTagsNotifier(super.state, this.repo);

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
