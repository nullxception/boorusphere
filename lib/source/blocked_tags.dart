import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final blockedTagsProvider =
    StateNotifierProvider<BlockedTagsSource, Map<int, String>>((ref) {
  final storage = BlockedTagsSource._storage;
  return BlockedTagsSource(ref, Map.from(storage.toMap()));
});

class BlockedTagsSource extends StateNotifier<Map<int, String>> {
  BlockedTagsSource(this.ref, super.state);

  final Ref ref;

  void _refresh() {
    state = Map.from(_storage.toMap());
  }

  Future<void> delete(key) async {
    await _storage.delete(key);
    _refresh();
  }

  Future<void> push(String value) async {
    final tag = value.trim();
    if (tag.isEmpty) return;

    if (!_storage.values.contains(tag)) {
      await _storage.add(tag);
    }
    _refresh();
  }

  Future<void> pushAll(List<String> values) async {
    for (var tag in values) {
      await push(tag);
    }
  }

  static Box get _storage => Hive.box('blockedTags');
}
