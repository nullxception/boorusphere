import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedSafeMode =
    FutureProvider<bool>((ref) async => await SafeModeState.restore(ref));

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final fromSettings = ref
      .watch(_savedSafeMode)
      .maybeWhen(data: (data) => data, orElse: () => true);

  return SafeModeState(ref, fromSettings);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(this.ref, initData) : super(initData);

  final Ref ref;

  Future<void> enable(bool value) async {
    state = value;
    final settings = await ref.read(settingsBox);
    settings.put(boxKey, value);
  }

  static Future<bool> restore(FutureProviderRef futureRef) async {
    final settings = await futureRef.read(settingsBox);
    return settings.get(boxKey, defaultValue: true);
  }

  static const boxKey = 'server_safe_mode';
}
