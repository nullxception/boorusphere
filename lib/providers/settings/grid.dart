import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/settings.dart';

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  final fromSettings = Settings.timeline_grid_number.read(or: 0);
  return GridState(fromSettings);
});

class GridState extends StateNotifier<int> {
  GridState(int initState) : super(initState);

  void rotate() {
    state = state < 2 ? state + 1 : 0;
    Settings.timeline_grid_number.save(state);
  }
}
