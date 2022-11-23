import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/blocked_tags_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blocked_tags_state.g.dart';

@Riverpod(keepAlive: true)
class BlockedTagsState extends _$BlockedTagsState {
  late BlockedTagsRepo _repo;

  @override
  Map<int, String> build() {
    _repo = ref.read(blockedTagsRepoProvider);
    return _repo.get();
  }

  Future<void> delete(key) async {
    await _repo.delete(key);
    state = _repo.get();
  }

  Future<void> push(String value) async {
    await _repo.push(value);
    state = _repo.get();
  }

  Future<void> pushAll(List<String> values) async {
    for (var tag in values) {
      await _repo.push(tag);
    }
    state = _repo.get();
  }
}
