import 'dart:convert';

import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
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
      if (key == Setting.downloadsQuality.name) {
        await box.put(key, DownloadQuality.fromName(value));
      } else if (key == Setting.searchRating.name) {
        await box.put(key, BooruRating.fromName(value));
      } else if (key == Setting.serverActive.name) {
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
        if (value is DownloadQuality) {
          return MapEntry(key, value.name);
        } else if (value is BooruRating) {
          return MapEntry(key, value.name);
        } else if (key == Setting.serverActive.name) {
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
  }
}
