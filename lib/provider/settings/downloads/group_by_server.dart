import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final groupByServerProvider =
    StateNotifierProvider<GroupByServerState, bool>((ref) {
  final box = Hive.box('settings');
  final fromSettings = box.get(GroupByServerState.boxKey, defaultValue: false);
  return GroupByServerState(ref, fromSettings);
});

class GroupByServerState extends StateNotifier<bool> {
  GroupByServerState(this.ref, bool initState) : super(initState);

  final Ref ref;

  void enable(bool value) {
    state = value;
    Hive.box('settings').put(boxKey, value);
  }

  static const boxKey = 'download_group_by_server';
}
