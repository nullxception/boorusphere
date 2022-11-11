import 'package:boorusphere/data/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverActiveProvider =
    StateNotifierProvider<ServerActiveState, ServerData>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(Setting.serverActive, or: ServerData.empty);
  return ServerActiveState(saved, repo);
});

class ServerActiveState extends StateNotifier<ServerData> {
  ServerActiveState(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(ServerData data) async {
    state = data;
    await repo.put(Setting.serverActive, data);
  }
}
