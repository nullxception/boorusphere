import 'dart:convert';

import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/data/repository/setting/migrator/setting_migrator.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:hive/hive.dart';

class SettingLocalSource {
  SettingLocalSource(this.box);

  final Box box;

  T get<T>(String name, {required T or}) => box.get(name) ?? or;

  Future<void> put<T>(String name, T value) => box.put(name, value);

  Future<void> import(String src) async {
    final Map map = jsonDecode(src);
    if (map.isEmpty) return;
    await box.deleteAll(box.keys);
    map.forEach((key, value) async {
      if (key == Setting.serverActive.name) {
        await box.put(key, ServerData.fromJson(Map.from(value)));
      } else {
        await box.put(key, value);
      }
    });
  }

  Future<BackupItem> export() async {
    return BackupItem(
      key,
      box.toMap().map((key, value) {
        if (key == Setting.serverActive.name) {
          return MapEntry(key, value.toJson());
        } else {
          return MapEntry(key, value);
        }
      }),
    );
  }

  static const String key = 'settings';
  static Future<void> prepare() async {
    await Hive.openBox(key);
    await migrateSetting();
  }
}
