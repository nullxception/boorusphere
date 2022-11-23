import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_setting_state.g.dart';

@riverpod
class DownloadSettingState extends _$DownloadSettingState {
  late SettingRepo _repo;

  @override
  DownloadSetting build() {
    _repo = ref.read(settingRepoProvider);
    return DownloadSetting(
      groupByServer: _repo.get(Setting.downloadsGroupByServer, or: false),
    );
  }

  Future<void> setGroupByServer(bool value) async {
    state = state.copyWith(groupByServer: value);
    await _repo.put(Setting.downloadsGroupByServer, value);
  }
}
