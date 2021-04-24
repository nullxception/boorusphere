import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common.dart';

class GridState extends StateNotifier<int> {
  GridState(this.read) : super(0) {
    restoreFromPreference();
  }

  static const gridKey = 'timeline_grid_number';
  final Reader read;

  Future<void> restoreFromPreference() async {
    final prefs = await read(settingsBox);
    state = prefs.get(gridKey) ?? 0;
  }

  Future<void> rotate() async {
    state = state < 2 ? state + 1 : 0;
    final prefs = await read(settingsBox);
    prefs.put(gridKey, state);
  }
}
