import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings.dart';

final groupByServerProvider =
    StateNotifierProvider<GroupByServerState, bool>((ref) {
  final saved = Settings.download_group_by_server.read(or: false);
  return GroupByServerState(saved);
});

class GroupByServerState extends StateNotifier<bool> {
  GroupByServerState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.download_group_by_server.save(value);
  }
}
