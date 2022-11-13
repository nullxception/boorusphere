import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerActiveState extends StateNotifier<ServerData> {
  ServerActiveState(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(ServerData data) async {
    state = data;
    await repo.put(Setting.serverActive, data);
  }
}
