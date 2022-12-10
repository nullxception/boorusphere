import 'dart:convert';

import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/provider/data_backup.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServerLocalSource {
  ServerLocalSource({required this.assetBundle, required this.box});
  final AssetBundle assetBundle;
  final Box<ServerData> box;

  List<ServerData> get servers => box.values.toList();

  Future<void> _migrateKeys() async {
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

  Future<Map<String, ServerData>> loadServerJson() async {
    final json = await assetBundle.loadString('assets/servers.json');
    final servers = jsonDecode(json) as List;

    return Map.fromEntries(servers.map((it) {
      final value = ServerData.fromJson(it);
      return MapEntry(value.key, value);
    }));
  }

  Future<void> populate() async {
    final def = await loadServerJson();
    if (def.isEmpty) return;

    if (box.isEmpty) {
      await box.putAll(def);
    } else {
      await _migrateKeys();
    }
  }

  Future<void> add(ServerData data) async {
    await box.put(
      data.key,
      data.apiAddr == data.homepage ? data.copyWith(apiAddr: '') : data,
    );
  }

  Future<ServerData> edit(ServerData from, ServerData to) async {
    final data = to.apiAddr == to.homepage
        ? to.copyWith(id: from.id, apiAddr: '')
        : to.copyWith(id: from.id);

    await box.put(from.key, data);
    return data;
  }

  Future<void> reset() async {
    final defaults = await loadServerJson();
    await box.deleteAll(box.keys);
    await box.putAll(defaults);
  }

  Future<void> remove(ServerData data) async {
    await box.delete(data.key);
  }

  Future<void> import(String src) async {
    final List maps = jsonDecode(src);
    if (maps.isEmpty) return;
    await box.deleteAll(box.keys);
    for (final map in maps) {
      if (map is Map<String, dynamic>) {
        final server = ServerData.fromJson(map);
        await add(server);
      }
    }
  }

  Future<BackupItem> export() async {
    return BackupItem(key, box.values.map((e) => e.toJson()).toList());
  }

  static const String key = 'server';
  static Future<void> prepare() => Hive.openBox<ServerData>(key);
}
