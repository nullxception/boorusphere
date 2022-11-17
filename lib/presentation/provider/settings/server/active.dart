import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active.g.dart';

@riverpod
class ServerActiveSettingState extends _$ServerActiveSettingState {
  late SettingRepo repo;

  @override
  ServerData build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.serverActive, or: ServerData.empty);
  }

  Future<void> update(ServerData data) async {
    state = data;
    await repo.put(Setting.serverActive, data);
  }
}
