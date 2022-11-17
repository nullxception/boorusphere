import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/server/active.dart';
import 'package:boorusphere/presentation/provider/settings/server/post_limit.dart';
import 'package:boorusphere/presentation/provider/settings/server/safe_mode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerSettingsProvider {
  static final safeMode =
      StateNotifierProvider<SafeModeSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.serverSafeMode, or: true);
    return SafeModeSettingNotifier(saved, repo);
  });

  static final active =
      StateNotifierProvider<ServerActiveSettingNotifier, ServerData>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.serverActive, or: ServerData.empty);
    return ServerActiveSettingNotifier(saved, repo);
  });

  static final postLimit =
      StateNotifierProvider<ServerPostLimitSettingNotifier, int>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(
      Setting.serverPostLimit,
      or: ServerPostLimitSettingNotifier.defaultLimit,
    );
    return ServerPostLimitSettingNotifier(saved, repo);
  });
}
