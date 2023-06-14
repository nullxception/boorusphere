import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/server/entity/server_auth.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_auth_state.g.dart';

@Riverpod(keepAlive: true)
class ServerAuthState extends _$ServerAuthState {
  @override
  Iterable<ServerAuth> build() {
    final repo = ref.read(serverRepoProvider);
    return repo.authentications;
  }

  Future<void> update(ServerAuth data) async {
    final repo = ref.read(serverRepoProvider);
    await repo.updateAuth(data);
    state = repo.authentications;
  }
}

extension ServerAuthListExt on Iterable<ServerAuth> {
  ServerAuth on(Server server) {
    return firstWhere((it) => it.serverId == server.id,
        orElse: () => ServerAuth.empty);
  }
}
