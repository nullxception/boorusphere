import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';

abstract interface class ServerDataRepo {
  Iterable<ServerData> get servers;
  Map<String, ServerData> get defaults;
  Future<void> populate();
  Future<void> add(ServerData data);
  Future<ServerData> edit(ServerData from, ServerData to);
  Future<void> remove(ServerData data);
  Future<void> reset();
  Future<void> import(String src);
  Future<BackupItem> export();
}
