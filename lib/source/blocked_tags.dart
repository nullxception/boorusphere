import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final blockedTagsProvider = Provider(BlockedTagsSource.new);

class BlockedTagsSource {
  BlockedTagsSource(this.ref);
  final Ref ref;

  Box get _box => Hive.box('blockedTags');

  Map get mapped => _box.toMap();

  List<String> get listedEntries {
    return _box.values.map((it) => it.toString()).toList();
  }

  void delete(key) {
    _box.delete(key);
  }

  bool checkExists({required String value}) {
    if (_box.isEmpty) return false;

    return value ==
        _box.values.firstWhere((it) => it == value, orElse: () => '');
  }

  void push(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;

    if (!checkExists(value: tag)) {
      _box.add(tag);
    }
  }

  void pushAll(List<String> values) {
    for (var tag in values) {
      push(tag);
    }
  }
}
