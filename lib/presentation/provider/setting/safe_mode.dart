import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(Setting.serverSafeMode, or: true);
  return SafeModeState(saved, repo);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(super.state, this.repo);
  final SettingRepo repo;

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.serverSafeMode, value);
  }
}
