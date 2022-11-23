import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blocked_tags_state.g.dart';

@Riverpod(keepAlive: true)
class BlockedTagsState extends _$BlockedTagsState {
  late BlockedTagsRepo repo;

  @override
  Map<int, String> build() {
    repo = ref.read(blockedTagsRepoProvider);
    return repo.get();
  }

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
