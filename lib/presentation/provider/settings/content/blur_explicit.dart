import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blur_explicit.g.dart';

@riverpod
class BlurExplicitPostSettingState extends _$BlurExplicitPostSettingState {
  late SettingRepo repo;

  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.postBlurExplicit, or: true);
  }

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.postBlurExplicit, value);
  }
}
