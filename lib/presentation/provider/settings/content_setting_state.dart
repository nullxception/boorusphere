import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/provider/settings/entity/content_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_setting_state.g.dart';

@riverpod
class ContentSettingState extends _$ContentSettingState {
  late SettingRepo repo;

  @override
  ContentSetting build() {
    repo = ref.read(settingRepoProvider);
    return ContentSetting(
      blurExplicit: repo.get(Setting.postBlurExplicit, or: true),
      loadOriginal: repo.get(Setting.postLoadOriginal, or: false),
      videoMuted: repo.get(Setting.videoPlayerMuted, or: false),
    );
  }

  Future<void> setBlurExplicitPost(bool value) async {
    state = state.copyWith(blurExplicit: value);
    await repo.put(Setting.postBlurExplicit, value);
  }

  Future<void> setLoadOriginalPost(bool value) async {
    state = state.copyWith(loadOriginal: value);
    await repo.put(Setting.postLoadOriginal, value);
  }

  Future<bool> toggleVideoPlayerMute() async {
    state = state.copyWith(videoMuted: !state.videoMuted);
    await repo.put(Setting.videoPlayerMuted, state);
    return state.videoMuted;
  }
}
