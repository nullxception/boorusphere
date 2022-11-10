import 'package:hive_flutter/hive_flutter.dart';

class BlockedTagsLocalSource {
  BlockedTagsLocalSource(this.box);

  final Box box;

  Map<int, String> get() {
    return Map.from(box.toMap());
  }

  Future<void> delete(key) async {
    await box.delete(key);
  }

  Future<void> push(String value) async {
    final tag = value.trim();
    if (tag.isEmpty) return;

    if (!box.values.contains(tag)) {
      await box.add(tag);
    }
  }

  static String key = 'blockedTags';
}
