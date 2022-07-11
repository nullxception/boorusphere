import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'hive_boxes.dart';

class BlockedTagsRepository {
  final Reader read;

  BlockedTagsRepository(this.read);

  Future<Map> get mapped async {
    final blocked = await read(blockedTagsBox);
    return blocked.toMap();
  }

  Future<List<String>> get listedEntries async {
    final blocked = await read(blockedTagsBox);
    return blocked.values.map((it) => it.toString()).toList();
  }

  Future<void> delete(key) async {
    final blocked = await read(blockedTagsBox);
    blocked.delete(key);
  }

  Future<bool> checkExists({required String value}) async {
    final blocked = await read(blockedTagsBox);
    if (blocked.isEmpty) return false;

    return value ==
        blocked.values.firstWhere((it) => it == value, orElse: () => '');
  }

  Future<void> push(String value) async {
    final tag = value.trim();
    if (tag.isEmpty) return;

    final blocked = await read(blockedTagsBox);
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

final blockedTagsProvider = Provider((ref) => BlockedTagsRepository(ref.read));
