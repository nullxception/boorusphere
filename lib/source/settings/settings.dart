import 'package:hive/hive.dart';

import 'migrator/keysmigrator.dart';

enum Settings {
  downloadsGroupByServer,
  postBlurExplicit,
  serverActive,
  serverPostLimit,
  serverSafeMode,
  uiMidnightMode,
  uiBlur,
  uiThemeMode,
  uiTimelineGrid,
  videoPlayerMuted;

  T read<T>({required T or}) => storage.get(name) ?? or;
  Future<void> save<T>(T value) async => await storage.put(name, value);

  static Box get storage => Hive.box('settings');

  static Future<void> performMigration() async {
    await SettingKeysMigrator.performMigration();
  }
}
