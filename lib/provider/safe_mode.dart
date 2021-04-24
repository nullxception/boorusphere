import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common.dart';

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(this.read) : super(true);

  final Reader read;

  Future<void> init() async {
    final prefs = await read(settingsBox);
    state = prefs.get('server_safe_mode') ?? true;
  }

  Future<void> setMode({required bool safe}) async {
    state = safe;
    final prefs = await read(settingsBox);
    prefs.put('server_safe_mode', safe);
  }
}
