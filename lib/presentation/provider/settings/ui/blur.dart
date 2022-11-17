import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blur.g.dart';

@riverpod
class UiBlurSettingState extends _$UiBlurSettingState {
  late SettingRepo repo;

  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.uiBlur, or: false);
  }

  Future<bool> enable(bool value) async {
    state = value;
    await repo.put(Setting.uiBlur, value);
    return state;
  }
}
