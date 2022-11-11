import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupByServerProvider =
    StateNotifierProvider<GroupByServerState, bool>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(Setting.downloadsGroupByServer, or: false);
  return GroupByServerState(saved, repo);
});

class GroupByServerState extends StateNotifier<bool> {
  GroupByServerState(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.downloadsGroupByServer, value);
  }
}
