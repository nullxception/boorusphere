import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'hive_boxes.dart';
import 'settings/active_server.dart';

final serverDataProvider =
    StateNotifierProvider<ServersState, List<ServerData>>(
        (ref) => ServersState(ref.read));

class ServersState extends StateNotifier<List<ServerData>> {
  ServersState(this.read) : super([]);
  final Reader read;

  final _defaultServerList = <ServerData>[];

  Set<ServerData> get allWithDefaults =>
      <ServerData>{..._defaultServerList, ...state};

  Future<void> populateData() async {
    final server = await read(serverBox);

    final fromAssets = await _defaultServersAssets();
    _defaultServerList.addAll(fromAssets.values);

    if (server.isEmpty) {
      server.putAll(fromAssets);
    }
    state = server.values.map((it) => it as ServerData).toList();
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

  void addServer({required ServerData data}) async {
    final server = await read(serverBox);
    server.put(data.homepage, data);
    state = server.values.map((it) => it as ServerData).toList();
  }

  void removeServer({required ServerData data}) async {
    final activeServerNotifier = read(activeServerProvider.notifier);
    final activeServer = read(activeServerProvider);

    if (state.length == 1) {
      throw Exception('Last server cannot be deleted');
    }
    final server = await read(serverBox);
    server.delete(data.homepage);
    state = server.values.map((it) => it as ServerData).toList();
    if (activeServer == data) {
      activeServerNotifier.use(state.first);
    }
  }

  void resetToDefault() async {
    final server = await read(serverBox);
    final activeServerNotifier = read(activeServerProvider.notifier);

    final fromAssets = await _defaultServersAssets();

    server.deleteAll(server.keys);
    server.putAll(fromAssets);
    state = server.values.map((it) => it as ServerData).toList();

    activeServerNotifier.use(state.first);
  }

  Future<void> editServer({
    required ServerData data,
    required ServerData newData,
  }) async {
    final server = await read(serverBox);
    final activeServer = read(activeServerProvider);
    final activeServerNotifier = read(activeServerProvider.notifier);

    server.delete(data.homepage);
    server.put(data.homepage, newData);
    state = server.values.map((it) => it as ServerData).toList();
    if (activeServer == data && newData.name != activeServer.name) {
      activeServerNotifier.use(newData);
    }
  }
}
