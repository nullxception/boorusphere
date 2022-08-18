import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../entity/server_data.dart';
import '../settings.dart';

final serverActiveProvider =
    StateNotifierProvider<ServerActiveState, ServerData>((ref) {
  final saved = Settings.server_active.read(or: ServerData.empty);
  return ServerActiveState(saved);
});

class ServerActiveState extends StateNotifier<ServerData> {
  ServerActiveState(super.state);

  Future<void> update(ServerData data) async {
    state = data;
    await Settings.server_active.save(data);
  }
}