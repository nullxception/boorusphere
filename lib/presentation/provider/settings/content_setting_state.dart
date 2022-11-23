import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:boorusphere/presentation/provider/settings/entity/content_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_setting_state.g.dart';

@riverpod
class ContentSettingState extends _$ContentSettingState {
  late SettingRepo _repo;

  @override
  ContentSetting build() {
    _repo = ref.read(settingRepoProvider);
    return ContentSetting(
      blurExplicit: _repo.get(Setting.postBlurExplicit, or: true),
      loadOriginal: _repo.get(Setting.postLoadOriginal, or: false),
      videoMuted: _repo.get(Setting.videoPlayerMuted, or: false),
    );
  }

  Future<void> setBlurExplicitPost(bool value) async {
    state = state.copyWith(blurExplicit: value);
    await _repo.put(Setting.postBlurExplicit, value);
  }

  Future<void> setLoadOriginalPost(bool value) async {
    state = state.copyWith(loadOriginal: value);
    await _repo.put(Setting.postLoadOriginal, value);
  }

  Future<bool> toggleVideoPlayerMute() async {
    state = state.copyWith(videoMuted: !state.videoMuted);
    await _repo.put(Setting.videoPlayerMuted, state);
    return state.videoMuted;
  }
}
