import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/repository/server_repo.dart';

class ServerRepoImpl implements ServerRepo {
  ServerRepoImpl({required this.localSource});
  final ServerLocalSource localSource;

  @override
  List<ServerData> get servers => localSource.servers;

  @override
  Map<String, ServerData> defaults = {};

  @override
  Future<void> populate() async {
    defaults = localSource.defaultServers;
    await localSource.populate();
  }

  @override
  Future<void> add(ServerData data) => localSource.add(data);

  @override
  Future<ServerData> edit(ServerData from, ServerData to) =>
      localSource.edit(from, to);

  @override
  Future<void> reset() => localSource.reset();

  @override
  Future<void> remove(ServerData data) => localSource.remove(data);
}
