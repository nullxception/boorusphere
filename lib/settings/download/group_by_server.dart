import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/settings.dart';

final groupByServerProvider =
    StateNotifierProvider<GroupByServerState, bool>((ref) {
  final fromSettings = Settings.download_group_by_server.read(or: false);
  return GroupByServerState(fromSettings);
});

class GroupByServerState extends StateNotifier<bool> {
  GroupByServerState(super.initState);

  void enable(bool value) {
    state = value;
    Settings.download_group_by_server.save(value);
  }
}
