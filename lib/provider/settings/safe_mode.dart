import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final box = Hive.box('settings');
  final fromSettings = box.get(SafeModeState.boxKey, defaultValue: true);
  return SafeModeState(ref, fromSettings);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(this.ref, initData) : super(initData);

  final Ref ref;

  void enable(bool value) {
    state = value;
    Hive.box('settings').put(boxKey, value);
  }

  static const boxKey = 'server_safe_mode';
}
