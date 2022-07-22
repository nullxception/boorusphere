import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedSafeMode =
    FutureProvider<bool>((ref) async => await SafeModeState.restore(ref));

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final fromSettings = ref
      .read(_savedSafeMode)
      .maybeWhen(data: (data) => data, orElse: () => true);

  return SafeModeState(ref.read, fromSettings);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(this.read, initData) : super(initData);

  final Reader read;

  Future<void> enable(bool value) async {
    state = value;
    final settings = await read(settingsBox);
    settings.put(boxKey, value);
  }

  static Future<bool> restore(FutureProviderRef ref) async {
    final settings = await ref.read(settingsBox);
    return settings.get(boxKey, defaultValue: true);
  }

  static const boxKey = 'server_safe_mode';
}
