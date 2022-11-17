import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/server_repo.dart';
import 'package:boorusphere/presentation/provider/settings/server/active.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_data.g.dart';

@Riverpod(keepAlive: true)
class ServerDataState extends _$ServerDataState {
  late ServerRepo repo;

  @override
  List<ServerData> build() {
    repo = ref.read(serverRepoProvider);
    // execute it anonymously since we can't update other state
    // while constructing a state
    Future(_populate);
    return [];
  }

  Set<ServerData> get all => {...repo.defaults.values, ...state};

  ServerData get active => ref.read(serverActiveSettingStateProvider);

  ServerActiveSettingState get activeNotifier =>
      ref.read(serverActiveSettingStateProvider.notifier);

  Future<void> _populate() async {
    await repo.populate();
    state = repo.servers;

    if (state.isNotEmpty && active == ServerData.empty) {
      await activeNotifier
          .update(state.firstWhere((it) => it.id.startsWith('Safe')));
    }
  }

  ServerData getById(String id, {ServerData? or}) {
    return state.isEmpty
        ? ServerData.empty
        : state.firstWhere(
            (it) => it.id == id,
            orElse: () => or ?? state.first,
          );
  }

  Future<void> add(ServerData data) async {
    await repo.add(data);
    state = repo.servers;
  }

  Future<void> remove(ServerData data) async {
    if (state.length == 1) {
      throw Exception('Last server cannot be deleted');
    }

    await repo.remove(data);
    state = repo.servers;
    if (active == data) {
      await activeNotifier.update(state.first);
    }
  }

  Future<void> edit(ServerData from, ServerData to) async {
    final data = await repo.edit(from, to);
    state = repo.servers;
    if (active == from) {
      await activeNotifier.update(data);
    }
  }

  Future<void> reset() async {
    await repo.reset();
    state = repo.servers;
    await activeNotifier.update(state.first);
  }
}
