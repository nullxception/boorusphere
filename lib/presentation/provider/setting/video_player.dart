import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final repo = ref.watch(settingRepoProvider);
  final saved = repo.get(Setting.videoPlayerMuted, or: false);
  return VideoPlayerMuteState(saved, repo);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(super.state, this.repo);

  final SettingRepo repo;

  Future<bool> toggle() async {
    state = !state;
    await repo.put(Setting.videoPlayerMuted, state);
    return state;
  }
}
