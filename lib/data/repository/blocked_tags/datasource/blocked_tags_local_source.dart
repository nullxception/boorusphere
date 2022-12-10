import 'dart:convert';

import 'package:boorusphere/presentation/provider/data_backup.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BlockedTagsLocalSource {
  BlockedTagsLocalSource(this.box);

  final Box<String> box;

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

  Future<void> import(String src) async {
    final List tags = jsonDecode(src);
    if (tags.isEmpty) return;
    await box.deleteAll(box.keys);
    for (var element in tags) {
      if (element is String) {
        await push(element);
      }
    }
  }

  Future<BackupItem> export() async {
    return BackupItem(key, box.values.toList());
  }

  static const String key = 'blockedTags';
  static Future<void> prepare() => Hive.openBox<String>(key);
}
