import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  final box = Hive.box('settings');
  final fromSettings = box.get(GridState.boxKey, defaultValue: 0);
  return GridState(ref, fromSettings);
});

class GridState extends StateNotifier<int> {
  GridState(this.ref, int initState) : super(initState);

  final Ref ref;

  void rotate() {
    state = state < 2 ? state + 1 : 0;
    Hive.box('settings').put(boxKey, state);
  }

  static const boxKey = 'timeline_grid_number';
}
