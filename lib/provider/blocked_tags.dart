import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'hive_boxes.dart';

final blockedTagsProvider = Provider((ref) => BlockedTagsManager(ref));

class BlockedTagsManager {
  final Ref ref;

  BlockedTagsManager(this.ref);

  Future<Map> get mapped async {
    final blocked = await ref.read(blockedTagsBox);
    return blocked.toMap();
  }

  Future<List<String>> get listedEntries async {
    final blocked = await ref.read(blockedTagsBox);
    return blocked.values.map((it) => it.toString()).toList();
  }

  Future<void> delete(key) async {
    final blocked = await ref.read(blockedTagsBox);
    blocked.delete(key);
  }

  Future<bool> checkExists({required String value}) async {
    final blocked = await ref.read(blockedTagsBox);
    if (blocked.isEmpty) return false;

    return value ==
        blocked.values.firstWhere((it) => it == value, orElse: () => '');
  }

  Future<void> push(String value) async {
    final tag = value.trim();
    if (tag.isEmpty) return;

    final blocked = await ref.read(blockedTagsBox);
    if (!await checkExists(value: tag)) {
      blocked.add(tag);
    }
  }

  Future<void> pushAll(List<String> values) async {
    for (var tag in values) {
      await push(tag);
    }
  }
}
