import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/presentation/provider/data_backup/data_backup.dart';

abstract interface class SettingRepo {
  T get<T>(Setting key, {required T or});
  Future<void> put<T>(Setting key, T value);
  Future<void> import(String src);
  Future<BackupItem> export();
}
