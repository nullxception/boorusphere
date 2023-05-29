import 'package:boorusphere/data/repository/server/entity/server_data.dart';

abstract interface class ServerRepo {
  Iterable<ServerData> get servers;
  late Map<String, ServerData> defaults;
  Future<void> populate();
  Future<void> add(ServerData data);
  Future<ServerData> edit(ServerData from, ServerData to);
  Future<void> remove(ServerData data);
  Future<void> reset();
}
