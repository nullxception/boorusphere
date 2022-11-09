import 'package:hive_flutter/hive_flutter.dart';

abstract class SettingsMigrator {
  Box get storage => Hive.box('settings');
  void migrate();
  bool shouldMigrate();
}
