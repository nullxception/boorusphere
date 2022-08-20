import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  final saved = Settings.timeline_grid_number.read(or: 1);
  return GridState(saved);
});

class GridState extends StateNotifier<int> {
  GridState(super.state);

  Future<int> cycle() async {
    state = state < 2 ? state + 1 : 0;
    await Settings.timeline_grid_number.save(state);
    return state;
  }
}
