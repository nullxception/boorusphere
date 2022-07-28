import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/server_data.dart';
import '../server_data.dart';

final activeServerProvider =
    StateNotifierProvider<ActiveServerState, ServerData>(
        (ref) => ActiveServerState(ref));

class ActiveServerState extends StateNotifier<ServerData> {
  ActiveServerState(this.ref) : super(ServerData.empty);

  final Ref ref;

  Box get _box => Hive.box('settings');

  void restoreFromPreference() {
    final name = _box.get(boxKey, defaultValue: '');
    state = ref.read(serverDataProvider.notifier).select(name);
  }

  Future<void> use(ServerData data) async {
    state = data;
    await _box.put(boxKey, data.name);
  }

  static const boxKey = 'active_server';
}
