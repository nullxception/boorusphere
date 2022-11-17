import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_settings.freezed.dart';
part 'server_settings.g.dart';

@freezed
class ServerSettings with _$ServerSettings {
  const factory ServerSettings({
    @Default(ServerData.empty) ServerData active,
    @Default(false) bool safeMode,
    @Default(PageOption.defaultLimit) int postLimit,
  }) = _ServerSettings;
  const ServerSettings._();
}

@riverpod
class ServerSettingsState extends _$ServerSettingsState {
  late SettingRepo repo;

  @override
  ServerSettings build() {
    repo = ref.read(settingRepoProvider);
    return ServerSettings(
      active: repo.get(Setting.serverActive, or: ServerData.empty),
      postLimit: repo.get(Setting.serverPostLimit, or: PageOption.defaultLimit),
      safeMode: repo.get(Setting.serverSafeMode, or: true),
    );
  }

  Future<void> setActiveServer(ServerData value) async {
    state = state.copyWith(active: value);
    await repo.put(Setting.serverActive, value);
  }

  Future<void> setPostLimit(int value) async {
    state = state.copyWith(postLimit: value);
    await repo.put(Setting.serverPostLimit, value);
  }

  Future<void> setSafeMode(bool value) async {
    state = state.copyWith(safeMode: value);
    await repo.put(Setting.serverSafeMode, value);
  }
}
