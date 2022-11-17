import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerActiveSettingNotifier extends StateNotifier<ServerData> {
  ServerActiveSettingNotifier(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(ServerData data) async {
    state = data;
    await repo.put(Setting.serverActive, data);
  }
}
