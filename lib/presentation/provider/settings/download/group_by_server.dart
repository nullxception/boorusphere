import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_by_server.g.dart';

@riverpod
class DownloadGroupByServerSettingState
    extends _$DownloadGroupByServerSettingState {
  late SettingRepo repo;
  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.downloadsGroupByServer, or: false);
  }

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.downloadsGroupByServer, value);
  }
}
