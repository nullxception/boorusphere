import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../entity/server_data.dart';
import '../settings/server/active.dart';

final _defaultData = FutureProvider((ref) => ServerDataLoader.loadDefaults());

final _savedData = FutureProvider((ref) {
  final defaults = ref.watch(_defaultData);
  return ServerDataLoader.loadSaved(
      defaults.maybeWhen(data: (data) => data, orElse: () => {}));
});

final serverDataProvider =
    StateNotifierProvider<ServerDataSource, List<ServerData>>((ref) {
  final defaults = ref.watch(_defaultData);
  final saved = ref.watch(_savedData);
  return ServerDataSource(
    ref,
    saved.maybeWhen(data: (data) => data, orElse: () => []),
    defaults.maybeWhen(data: (data) => data, orElse: () => {}),
  );
});

class ServerDataLoader {
  static Future<void> validateAndMigrateKeys(Box box) async {
    final mapped = Map<String, ServerData>.from(box.toMap());
    for (final data in mapped.entries) {
      if (data.key.startsWith('@')) {
        continue;
      }
      await box.delete(data.key);
      await box.put(data.value.key, data.value);
    }
    await box.flush();
  }

  static Future<Map<String, ServerData>> loadDefaults() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final servers = jsonDecode(json) as List;

    return Map.fromEntries(servers.map((it) {
      final value = ServerData.fromJson(it);
      return MapEntry(value.key, value);
    }));
  }

  static Future<List<ServerData>> loadSaved(defaultServers) async {
    if (defaultServers.isEmpty) return [];

    final box = Hive.box('server');
    if (box.isEmpty) {
      await box.putAll(defaultServers);
    } else {
      await validateAndMigrateKeys(box);
    }
    return box.values.map((it) => it as ServerData).toList();
  }
}

class ServerDataSource extends StateNotifier<List<ServerData>> {
  ServerDataSource(this.ref, super.state, this.defaults) {
    if (super.state.isNotEmpty) {
      // execute it anonymously since we can't update other state
      // while constructing a state
      Future.delayed(Duration.zero, () => _initLazily(ref, super.state));
    }
  }

  final Ref ref;
  final Map<String, ServerData> defaults;

  Box get _box => Hive.box('server');

  Set<ServerData> get allWithDefaults => {...defaults.values, ...state};

  ServerData get serverActive => ref.read(serverActiveProvider);
  ServerActiveState get serverActiveNotifier =>
      ref.read(serverActiveProvider.notifier);

  Future<void> _initLazily(Ref ref, List<ServerData> servers) async {
    if (serverActive == ServerData.empty) {
      await serverActiveNotifier
          .updateWith(servers.firstWhere((it) => it.name.startsWith('Safe')));
    }
  }

  void reloadFromBox() {
    state = _box.values.map((it) => it as ServerData).toList();
  }

  ServerData select(String name) {
    return state.isEmpty
        ? ServerData.empty
        : state.firstWhere((element) => element.name == name,
            orElse: () => state.first);
  }

  Future<void> add({required ServerData data}) async {
    await _box.put(data.key, data);
    reloadFromBox();
  }

  void delete({required ServerData data}) {
    if (state.length == 1) {
      throw Exception('Last server cannot be deleted');
    }
    _box.delete(data.key);
    reloadFromBox();
    if (serverActive == data) {
      serverActiveNotifier.updateWith(state.first);
    }
  }

  Future<void> edit({
    required ServerData data,
    required ServerData newData,
  }) async {
    await _box.delete(data.key);
    await _box.put(newData.key, newData);
    reloadFromBox();
    if (serverActive == data && newData.key != serverActive.key) {
      await serverActiveNotifier.updateWith(newData);
    }
  }

  Future<void> reset() async {
    await _box.deleteAll(_box.keys);
    await _box.putAll(defaults);
    reloadFromBox();
    await serverActiveNotifier.updateWith(state.first);
  }
}
