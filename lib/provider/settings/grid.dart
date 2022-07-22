import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedGrid =
    FutureProvider<int>((ref) async => await GridState.restore(ref));

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  final fromSettings =
      ref.watch(_savedGrid).maybeWhen(data: (data) => data, orElse: () => 0);

  return GridState(ref.read, fromSettings);
});

class GridState extends StateNotifier<int> {
  GridState(this.read, int initState) : super(initState);

  final Reader read;

  Future<void> rotate() async {
    state = state < 2 ? state + 1 : 0;
    final settings = await read(settingsBox);
    settings.put(boxKey, state);
  }

  static Future<int> restore(FutureProviderRef ref) async {
    final settings = await ref.read(settingsBox);
    return settings.get(boxKey, defaultValue: 0);
  }

  static const boxKey = 'timeline_grid_number';
}
