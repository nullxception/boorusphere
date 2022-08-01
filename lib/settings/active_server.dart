import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entity/server_data.dart';
import '../source/server.dart';
import '../utils/settings.dart';

final activeServerProvider =
    StateNotifierProvider<ActiveServerState, ServerData>((ref) {
  return ActiveServerState();
});

class ActiveServerState extends StateNotifier<ServerData> {
  ActiveServerState() : super(ServerData.empty);

  void restore(ServerDataSource serverData) {
    final name = Settings.active_server.read(or: '');
    state = serverData.select(name);
  }

  Future<void> use(ServerData data) async {
    state = data;
    await Settings.active_server.save(data.name);
  }
}
