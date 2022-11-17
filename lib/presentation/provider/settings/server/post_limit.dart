import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_limit.g.dart';

@riverpod
class PostLimitSettingState extends _$PostLimitSettingState {
  late SettingRepo repo;

  @override
  int build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.serverPostLimit, or: PageOption.defaultLimit);
  }

  Future<void> update(int value) async {
    state = value;
    await repo.put(Setting.serverPostLimit, value);
  }
}
