import 'package:deep_pick/deep_pick.dart';

import 'string.dart';

extension PickExt on Pick {
  List<String> asStringList({String or = ''}) {
    return asListOrEmpty((r) => r.asStringOrNull() ?? or)
        .where((it) => it.isNotEmpty)
        .toList();
  }

  List<String> toWordList({List<String> or = const <String>[]}) {
    return asStringOrNull()?.toWordList() ?? or;
  }
}
