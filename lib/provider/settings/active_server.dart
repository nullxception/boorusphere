import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/server_data.dart';
import '../hive_boxes.dart';
import '../server_data.dart';

final activeServerProvider =
    StateNotifierProvider<ActiveServerState, ServerData>(
        (ref) => ActiveServerState(ref.read));

class ActiveServerState extends StateNotifier<ServerData> {
  ActiveServerState(this.read) : super(ServerData.empty);

  final Reader read;

  Future<void> restoreFromPreference() async {
    final settings = await read(settingsBox);
    final serverDataNotifier = read(serverDataProvider.notifier);
    final name = settings.get(boxKey) ?? '';
    state = serverDataNotifier.select(name);
  }

  Future<void> use(ServerData data) async {
    state = data;
    final settings = await read(settingsBox);
    settings.put(boxKey, data.name);
  }

  static const boxKey = 'active_server';
}
