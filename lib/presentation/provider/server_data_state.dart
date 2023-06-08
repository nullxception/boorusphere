import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_data_state.g.dart';

@Riverpod(keepAlive: true)
class ServerDataState extends _$ServerDataState {
  @override
  Iterable<ServerData> build() {
    // populate later
    return [];
  }

  ServerSettingState get settings =>
      ref.read(serverSettingStateProvider.notifier);

  Future<void> populate() async {
    final serverSetting = ref.read(serverSettingStateProvider);
    final repo = ref.read(serverDataRepoProvider);
    await repo.populate();
    state = repo.servers;

    if (state.isNotEmpty && serverSetting.lastActiveId.isEmpty) {
      final server = state.firstWhere(
        (it) => it.id.startsWith('Safe'),
        orElse: () => state.first,
      );
      await settings.setLastActiveId(server.id);
    }
  }

  Future<void> add(ServerData data) async {
    final repo = ref.read(serverDataRepoProvider);
    await repo.add(data);
    state = repo.servers;
  }

  Future<void> remove(ServerData data) async {
    if (state.length == 1) {
      throw Exception('Last server cannot be deleted');
    }

    final repo = ref.read(serverDataRepoProvider);
    await repo.remove(data);
    state = repo.servers;
  }

  Future<void> edit(ServerData from, ServerData to) async {
    final repo = ref.read(serverDataRepoProvider);
    await repo.edit(from, to);
    state = repo.servers;
  }

  Future<void> reset() async {
    final repo = ref.read(serverDataRepoProvider);
    await repo.reset();
    state = repo.servers;
    await settings.setLastActiveId(state.first.id);
  }
}

extension ServerDataListExt on Iterable<ServerData> {
  ServerData getById(String id, {ServerData? or}) {
    return isEmpty
        ? ServerData.empty
        : firstWhere(
            (it) => it.id == id,
            orElse: () => or ?? first,
          );
  }
}
