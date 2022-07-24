import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../model/server_data.dart';
import 'settings/active_server.dart';

final serverDataProvider =
    StateNotifierProvider<ServersState, List<ServerData>>(
        (ref) => ServersState(ref));

class ServersState extends StateNotifier<List<ServerData>> {
  ServersState(this.ref) : super([]);

  final Ref ref;
  final _defaultServerList = <ServerData>[];

  Box get _box => Hive.box('server');

  Set<ServerData> get allWithDefaults =>
      <ServerData>{..._defaultServerList, ...state};

  Future<void> populateData() async {
    final fromAssets = await _defaultServersAssets();
    _defaultServerList.addAll(fromAssets.values);

    if (_box.isEmpty) {
      await _box.putAll(fromAssets);
    }
    state = _box.values.map((it) => it as ServerData).toList();
  }

  Future<Map<String, ServerData>> _defaultServersAssets() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final servers = jsonDecode(json) as List;

    return Map.fromEntries(servers.map((it) {
      final value = ServerData.fromJson(it);
      return MapEntry(value.homepage, value);
    }));
  }

  ServerData select(String name) {
    return state.isEmpty
        ? ServerData.empty
        : state.firstWhere((element) => element.name == name,
            orElse: () => state.first);
  }

  Future<void> addServer({required ServerData data}) async {
    await _box.put(data.homepage, data);
    state = _box.values.map((it) => it as ServerData).toList();
  }

  void removeServer({required ServerData data}) {
    final activeServerNotifier = ref.read(activeServerProvider.notifier);
    final activeServer = ref.read(activeServerProvider);

    if (state.length == 1) {
      throw Exception('Last server cannot be deleted');
    }
    _box.delete(data.homepage);
    state = _box.values.map((it) => it as ServerData).toList();
    if (activeServer == data) {
      activeServerNotifier.use(state.first);
    }
  }

  Future<void> resetToDefault() async {
    final activeServerNotifier = ref.read(activeServerProvider.notifier);

    final fromAssets = await _defaultServersAssets();

    await _box.deleteAll(_box.keys);
    await _box.putAll(fromAssets);
    state = _box.values.map((it) => it as ServerData).toList();

    activeServerNotifier.use(state.first);
  }

  Future<void> editServer({
    required ServerData data,
    required ServerData newData,
  }) async {
    final activeServer = ref.read(activeServerProvider);
    final activeServerNotifier = ref.read(activeServerProvider.notifier);

    await _box.delete(data.homepage);
    await _box.put(data.homepage, newData);
    state = _box.values.map((it) => it as ServerData).toList();
    if (activeServer == data && newData.name != activeServer.name) {
      activeServerNotifier.use(newData);
    }
  }
}
