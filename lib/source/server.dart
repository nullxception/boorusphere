import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../settings/active_server.dart';
import '../entity/server_data.dart';

final serverDataProvider =
    StateNotifierProvider<ServerDataSource, List<ServerData>>(
        ServerDataSource.new);

class ServerDataSource extends StateNotifier<List<ServerData>> {
  ServerDataSource(this.ref) : super([]);

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
    } else {
      await validateAndMigrateKeys();
    }
    state = _box.values.map((it) => it as ServerData).toList();
  }

  Future<Map<String, ServerData>> _defaultServersAssets() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final servers = jsonDecode(json) as List;

    return Map.fromEntries(servers.map((it) {
      final value = ServerData.fromJson(it);
      return MapEntry(value.key, value);
    }));
  }

  ServerData select(String name) {
    return state.isEmpty
        ? ServerData.empty
        : state.firstWhere((element) => element.name == name,
            orElse: () => state.first);
  }

  Future<void> addServer({required ServerData data}) async {
    await _box.put(data.key, data);
    state = _box.values.map((it) => it as ServerData).toList();
  }

  void removeServer({required ServerData data}) {
    final activeServer = ref.read(activeServerProvider);

    if (state.length == 1) {
      throw Exception('Last server cannot be deleted');
    }
    _box.delete(data.key);
    state = _box.values.map((it) => it as ServerData).toList();
    if (activeServer == data) {
      ref.read(activeServerProvider.notifier).use(state.first);
    }
  }

  Future<void> resetToDefault() async {
    final fromAssets = await _defaultServersAssets();

    await _box.deleteAll(_box.keys);
    await _box.putAll(fromAssets);
    state = _box.values.map((it) => it as ServerData).toList();

    await ref.read(activeServerProvider.notifier).use(state.first);
  }

  Future<void> editServer({
    required ServerData data,
    required ServerData newData,
  }) async {
    final activeServer = ref.read(activeServerProvider);

    await _box.delete(data.key);
    await _box.put(newData.key, newData);
    state = _box.values.map((it) => it as ServerData).toList();
    if (activeServer == data && newData.key != activeServer.key) {
      await ref.read(activeServerProvider.notifier).use(newData);
    }
  }

  Future<void> validateAndMigrateKeys() async {
    final mapped = Map<String, ServerData>.from(_box.toMap());
    for (final data in mapped.entries) {
      if (data.key.startsWith('@')) {
        continue;
      }
      await _box.delete(data.key);
      await _box.put(data.value.key, data.value);
    }
    await _box.flush();
  }
}
