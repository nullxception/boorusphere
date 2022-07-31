import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/settings.dart';

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final fromSettings = Settings.server_safe_mode.read(or: true);
  return SafeModeState(fromSettings);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(bool initData) : super(initData);

  void enable(bool value) {
    state = value;
    Settings.server_safe_mode.save(value);
  }
}
