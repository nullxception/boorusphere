import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/server_data.dart';
import '../../utils/settings.dart';
import '../server_data.dart';

final activeServerProvider =
    StateNotifierProvider<ActiveServerState, ServerData>((ref) {
  return ActiveServerState();
});

class ActiveServerState extends StateNotifier<ServerData> {
  ActiveServerState() : super(ServerData.empty);

  void restore(ServerManager serverData) {
    final name = Settings.active_server.read(or: '');
    state = serverData.select(name);
  }

  Future<void> use(ServerData data) async {
    state = data;
    await Settings.active_server.save(data.name);
  }
}
