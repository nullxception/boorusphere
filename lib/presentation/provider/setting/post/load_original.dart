import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadOriginalPostProvider =
    StateNotifierProvider<LoadOriginalPostState, bool>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(Setting.postLoadOriginal, or: false);
  return LoadOriginalPostState(saved, repo);
});

class LoadOriginalPostState extends StateNotifier<bool> {
  LoadOriginalPostState(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.postLoadOriginal, value);
  }
}
