import 'package:boorusphere/data/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  final saved = Settings.uiTimelineGrid.read(or: 1);
  return GridState(saved);
});

class GridState extends StateNotifier<int> {
  GridState(super.state);

  Future<int> cycle() async {
    state = state < 2 ? state + 1 : 0;
    await Settings.uiTimelineGrid.save(state);
    return state;
  }
}
