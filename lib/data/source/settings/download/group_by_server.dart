import 'package:boorusphere/data/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupByServerProvider =
    StateNotifierProvider<GroupByServerState, bool>((ref) {
  final saved = Settings.downloadsGroupByServer.read(or: false);
  return GroupByServerState(saved);
});

class GroupByServerState extends StateNotifier<bool> {
  GroupByServerState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.downloadsGroupByServer.save(value);
  }
}
