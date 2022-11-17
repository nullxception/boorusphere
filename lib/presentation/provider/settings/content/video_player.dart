import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_player.g.dart';

@riverpod
class VideoPlayerMuteSettingState extends _$VideoPlayerMuteSettingState {
  late SettingRepo repo;

  @override
  bool build() {
    repo = ref.read(settingRepoProvider);
    return repo.get(Setting.videoPlayerMuted, or: false);
  }

  Future<bool> toggle() async {
    state = !state;
    await repo.put(Setting.videoPlayerMuted, state);
    return state;
  }
}
