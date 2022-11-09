import 'package:boorusphere/data/source/settings/migrator/keysmigrator.dart';
import 'package:hive/hive.dart';

enum Settings {
  downloadsGroupByServer,
  postBlurExplicit,
  postLoadOriginal,
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
