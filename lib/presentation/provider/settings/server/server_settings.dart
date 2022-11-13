import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/presentation/provider/settings/server/active.dart';
import 'package:boorusphere/presentation/provider/settings/server/post_limit.dart';
import 'package:boorusphere/presentation/provider/settings/server/safe_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerSettingsProvider {
  static final safeMode = StateNotifierProvider<SafeModeState, bool>((ref) {
    final repo = ref.watch(settingRepoProvider);
    final saved = repo.get(Setting.serverSafeMode, or: true);
    return SafeModeState(saved, repo);
  });

  static final active =
      StateNotifierProvider<ServerActiveState, ServerData>((ref) {
    final repo = ref.watch(settingRepoProvider);
    final saved = repo.get(Setting.serverActive, or: ServerData.empty);
    return ServerActiveState(saved, repo);
  });

  static final postLimit =
      StateNotifierProvider<ServerPostLimitState, int>((ref) {
    final repo = ref.watch(settingRepoProvider);
    final saved = repo.get(
      Setting.serverPostLimit,
      or: ServerPostLimitState.defaultLimit,
    );
    return ServerPostLimitState(saved, repo);
  });
}
