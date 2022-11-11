import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/data/repository/setting/migrator/setting_keys_migrator.dart';
import 'package:hive/hive.dart';

abstract class SettingMigrator {
  void migrate();
  bool shouldMigrate();
}

Future<void> migrateSetting() async {
  final migrator = SettingKeysMigrator(Hive.box(SettingLocalSource.key));
  if (!migrator.shouldMigrate()) return;
  await migrator.migrate();
}
