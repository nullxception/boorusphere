import 'package:boorusphere/data/source/settings/migrator/migrator.dart';
import 'package:boorusphere/data/source/settings/settings.dart';

class SettingKeysMigrator extends SettingsMigrator {
  final Map<String, Settings> keys = {
    'blur_explicit_post': Settings.postBlurExplicit,
    'download_group_by_server': Settings.downloadsGroupByServer,
    'server_active': Settings.serverActive,
    'server_safe_mode': Settings.serverSafeMode,
    'server_post_limit': Settings.serverPostLimit,
    'theme_mode': Settings.uiThemeMode,
    'timeline_grid_number': Settings.uiTimelineGrid,
    'ui_theme_darker': Settings.uiMidnightMode,
    'videoplayer_mute': Settings.videoPlayerMuted,
  };

  @override
  Future<void> migrate() async {
    final oldSettings = Map.from(storage.toMap());
    final newSettings = oldSettings.map((k, v) => MapEntry(keys[k]?.name, v));
    newSettings.removeWhere((k, v) => k == null);

    await storage.deleteAll(keys.keys);
    await storage.putAll(newSettings);
    await storage.flush();
  }

  @override
  bool shouldMigrate() {
    return storage.keys.any((it) => it.contains('_'));
  }

  static Future<void> performMigration() async {
    final impl = SettingKeysMigrator();
    if (!impl.shouldMigrate()) return;
    await impl.migrate();
  }
}
