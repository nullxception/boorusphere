import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uiBlurProvider = StateNotifierProvider<UIBlurState, bool>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(Setting.uiBlur, or: false);
  return UIBlurState(saved, repo);
});

class UIBlurState extends StateNotifier<bool> {
  UIBlurState(super.state, this.repo);

  final SettingRepo repo;

  Future<bool> enable(bool value) async {
    state = value;
    await repo.put(Setting.uiBlur, value);
    return state;
  }
}
