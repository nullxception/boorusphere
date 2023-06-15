import 'dart:convert';

import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/domain/repository/server_data_repo.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:hive/hive.dart';

class UserServerRepo implements ServerRepo {
  UserServerRepo({
    required Map<String, Server> defaultServers,
    required this.box,
  }) : _defaults = defaultServers;

  final Map<String, Server> _defaults;
  final Box<Server> box;

  @override
  List<Server> get servers => box.values.toList();

  @override
  Map<String, Server> get defaults => _defaults;

  Future<void> _migrateKeys() async {
    final mapped = Map<String, Server>.from(box.toMap());
    for (final data in mapped.entries) {
      if (data.key.startsWith('@')) {
        continue;
      }
      await box.delete(data.key);
      await box.put(data.value.key, data.value);
    }
    await box.flush();
  }

  @override
  Future<void> populate() async {
    if (_defaults.isEmpty) return;

    if (box.isEmpty) {
      await box.putAll(_defaults);
    } else {
      await _migrateKeys();
    }
  }

  @override
  Future<void> add(Server data) async {
    await box.put(
      data.key,
      data.apiAddr == data.homepage ? data.copyWith(apiAddr: '') : data,
    );
  }

  @override
  Future<Server> edit(Server from, Server to) async {
    final data = to.apiAddr == to.homepage
        ? to.copyWith(id: from.id, apiAddr: '')
        : to.copyWith(id: from.id);

    await box.put(from.key, data);
    return data;
  }

  @override
  Future<void> reset() async {
    await box.deleteAll(box.keys);
    await box.putAll(_defaults);
  }

  @override
  Future<void> remove(Server data) async {
    await box.delete(data.key);
  }

  @override
  Future<void> import(String src) async {
    final List maps = jsonDecode(src);
    if (maps.isEmpty) return;
    await box.deleteAll(box.keys);
    for (final map in maps) {
      if (map is Map<String, dynamic>) {
        final server = Server.fromJson(map);
        await add(server);
      }
    }
  }

  @override
  Future<BackupItem> export() async {
    return BackupItem(key, box.values.map((e) => e.toJson()).toList());
  }

  static const String key = 'server';

  static Future<void> prepare() async {
    await Hive.openBox<Server>(key);
  }
}
