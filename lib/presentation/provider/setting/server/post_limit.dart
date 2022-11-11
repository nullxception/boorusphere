import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverPostLimitProvider =
    StateNotifierProvider<ServerPostLimitState, int>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(
    Setting.serverPostLimit,
    or: ServerPostLimitState.defaultLimit,
  );
  return ServerPostLimitState(saved, repo);
});

class ServerPostLimitState extends StateNotifier<int> {
  ServerPostLimitState(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(int value) async {
    state = value;
    await repo.put(Setting.serverPostLimit, value);
  }

  static const defaultLimit = 40;
}
