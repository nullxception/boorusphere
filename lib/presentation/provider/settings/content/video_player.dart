import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VideoPlayerMuteSettingNotifier extends StateNotifier<bool> {
  VideoPlayerMuteSettingNotifier(super.state, this.repo);

  final SettingRepo repo;

  Future<bool> toggle() async {
    state = !state;
    await repo.put(Setting.videoPlayerMuted, state);
    return state;
  }
}
