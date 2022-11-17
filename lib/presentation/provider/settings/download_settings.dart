import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_settings.freezed.dart';
part 'download_settings.g.dart';

@freezed
class DownloadSettings with _$DownloadSettings {
  const factory DownloadSettings({
    @Default(false) bool groupByServer,
  }) = _DownloadSettings;
}

@riverpod
class DownloadSettingsState extends _$DownloadSettingsState {
  late SettingRepo repo;

  @override
  DownloadSettings build() {
    repo = ref.read(settingRepoProvider);
    return DownloadSettings(
      groupByServer: repo.get(Setting.downloadsGroupByServer, or: false),
    );
  }

  Future<void> setGroupByServer(bool value) async {
    state = state.copyWith(groupByServer: value);
    await repo.put(Setting.downloadsGroupByServer, value);
  }
}
