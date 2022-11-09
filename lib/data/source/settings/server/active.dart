import 'package:boorusphere/data/entity/server_data.dart';
import 'package:boorusphere/data/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverActiveProvider =
    StateNotifierProvider<ServerActiveState, ServerData>((ref) {
  final saved = Settings.serverActive.read(or: ServerData.empty);
  return ServerActiveState(saved);
});

class ServerActiveState extends StateNotifier<ServerData> {
  ServerActiveState(super.state);

  Future<void> update(ServerData data) async {
    state = data;
    await Settings.serverActive.save(data);
  }
}
