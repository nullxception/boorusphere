import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'safe_mode.g.dart';

@riverpod
class SafeModeSettingState extends _$SafeModeSettingState {
  late SettingRepo repo;
  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.serverSafeMode, or: true);
  }

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.serverSafeMode, value);
  }
}
