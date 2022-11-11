import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/data/repository/setting/migrator/setting_migrator.dart';
import 'package:hive/hive.dart';

class SettingKeysMigrator extends SettingMigrator {
  SettingKeysMigrator(this.box);
  final Box box;
  final Map<String, Setting> keys = {
    'blur_explicit_post': Setting.postBlurExplicit,
    'download_group_by_server': Setting.downloadsGroupByServer,
    'server_active': Setting.serverActive,
    'server_safe_mode': Setting.serverSafeMode,
    'server_post_limit': Setting.serverPostLimit,
    'theme_mode': Setting.uiThemeMode,
    'timeline_grid_number': Setting.uiTimelineGrid,
    'ui_theme_darker': Setting.uiMidnightMode,
    'videoplayer_mute': Setting.videoPlayerMuted,
  };

  @override
  Future<void> migrate() async {
    final oldSettings = Map.from(box.toMap());
    final newSettings = oldSettings.map((k, v) => MapEntry(keys[k]?.name, v));
    newSettings.removeWhere((k, v) => k == null);

    await box.deleteAll(keys.keys);
    await box.putAll(newSettings);
    await box.flush();
  }

  @override
  bool shouldMigrate() {
    return box.keys.any((it) => it.contains('_'));
  }
}
