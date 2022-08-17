import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final saved = Settings.server_safe_mode.read(or: true);
  return SafeModeState(saved);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.server_safe_mode.save(value);
  }
}
