import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../hive_boxes.dart';

final _savedGroupByServer =
    FutureProvider<bool>((ref) async => await GroupByServerState.restore(ref));

final groupByServerProvider =
    StateNotifierProvider<GroupByServerState, bool>((ref) {
  final fromSettings = ref
      .watch(_savedGroupByServer)
      .maybeWhen(data: (data) => data, orElse: () => false);

  return GroupByServerState(ref, fromSettings);
});

class GroupByServerState extends StateNotifier<bool> {
  GroupByServerState(this.ref, bool initState) : super(initState);

  final Ref ref;

  Future<void> enable(bool value) async {
    state = value;
    final settings = await ref.read(settingsBox);
    settings.put(boxKey, value);
  }

  static const boxKey = 'download_group_by_server';

  static Future<bool> restore(FutureProviderRef futureRef) async {
    final settings = await futureRef.read(settingsBox);
    return settings.get(GroupByServerState.boxKey, defaultValue: false);
  }
}
