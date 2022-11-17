import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_original.g.dart';

@riverpod
class LoadOriginalPostSettingState extends _$LoadOriginalPostSettingState {
  late SettingRepo repo;

  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.postLoadOriginal, or: false);
  }

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.postLoadOriginal, value);
  }
}
