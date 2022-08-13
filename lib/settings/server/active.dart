import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/server_data.dart';
import '../../utils/settings.dart';

final serverActiveProvider =
    StateNotifierProvider<ServerActiveState, ServerData>((ref) {
  final fromSettings = Settings.server_active.read(or: ServerData.empty);
  return ServerActiveState(fromSettings);
});

class ServerActiveState extends StateNotifier<ServerData> {
  ServerActiveState(super.initData);

  Future<void> updateWith(ServerData data) async {
    state = data;
    await Settings.server_active.save(data);
  }
}
