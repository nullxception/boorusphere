import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_setting_state.g.dart';

@riverpod
class DownloadSettingState extends _$DownloadSettingState {
  @override
  DownloadSetting build() {
    final repo = ref.read(settingRepoProvider);
    return DownloadSetting(
      groupByServer: repo.get(Setting.downloadsGroupByServer, or: false),
      quality: repo.get(Setting.downloadsQuality, or: DownloadQuality.ask),
    );
  }

  Future<void> setGroupByServer(bool value) async {
    final repo = ref.read(settingRepoProvider);
    state = state.copyWith(groupByServer: value);
    await repo.put(Setting.downloadsGroupByServer, value);
  }

  Future<void> setQuality(DownloadQuality value) async {
    final repo = ref.read(settingRepoProvider);
    state = state.copyWith(quality: value);
    await repo.put(Setting.downloadsQuality, value);
  }
}
