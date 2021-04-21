import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common.dart';

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(this.read) : super(true);

  final Reader read;

  Future<void> restoreFromPreference() async {
    final prefs = await read(preferenceProvider);
    state = prefs.getBool('server_safe_mode') ?? true;
  }

  Future<void> setMode({required bool safe}) async {
    state = safe;
    final prefs = await read(preferenceProvider);
    prefs.setBool('server_safe_mode', safe);
  }
}
