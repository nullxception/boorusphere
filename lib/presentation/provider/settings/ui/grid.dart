import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grid.g.dart';

@riverpod
class GridSettingState extends _$GridSettingState {
  late SettingRepo repo;
  @override
  int build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.uiTimelineGrid, or: 1);
  }

  Future<int> cycle() async {
    state = state < 2 ? state + 1 : 0;
    await repo.put(Setting.uiTimelineGrid, state);
    return state;
  }
}
