import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/server_data.dart';
import '../hive_boxes.dart';
import '../server_data.dart';

final activeServerProvider =
    StateNotifierProvider<ActiveServerState, ServerData>(
        (ref) => ActiveServerState(ref));

class ActiveServerState extends StateNotifier<ServerData> {
  ActiveServerState(this.ref) : super(ServerData.empty);

  final Ref ref;

  Future<void> restoreFromPreference() async {
    final settings = await ref.read(settingsBox);
    final serverDataNotifier = ref.read(serverDataProvider.notifier);
    final name = settings.get(boxKey, defaultValue: '');
    state = serverDataNotifier.select(name);
  }

  Future<void> use(ServerData data) async {
    state = data;
    final settings = await ref.read(settingsBox);
    settings.put(boxKey, data.name);
  }

  static const boxKey = 'active_server';
}
