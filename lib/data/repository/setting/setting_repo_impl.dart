import 'dart:convert';

import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:hive/hive.dart';

class SettingRepoImpl implements SettingRepo {
  SettingRepoImpl(this.box);

  final Box box;

  @override
  T get<T>(Setting key, {required T or}) => box.get(key.name) ?? or;

  @override
  Future<void> put<T>(Setting key, T value) => box.put(key.name, value);

  @override
  Future<void> import(String src) async {
    final Map map = jsonDecode(src);
    if (map.isEmpty) return;
    await box.deleteAll(box.keys);
    map.forEach((key, value) async {
      if (key == Setting.downloadsQuality.name) {
        await box.put(key, DownloadQuality.fromName(value));
      } else if (key == Setting.searchRating.name) {
        await box.put(key, BooruRating.fromName(value));
      } else {
        await box.put(key, value);
      }
    });
  }

  @override
  Future<BackupItem> export() async {
    return BackupItem(
      key,
      box.toMap().map((key, value) {
        if (value is DownloadQuality) {
          return MapEntry(key, value.name);
        } else if (value is BooruRating) {
          return MapEntry(key, value.name);
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
