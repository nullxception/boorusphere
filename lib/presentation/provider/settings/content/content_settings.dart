import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/content/blur_explicit.dart';
import 'package:boorusphere/presentation/provider/settings/content/load_original.dart';
import 'package:boorusphere/presentation/provider/settings/content/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentSettingsProvider {
  static final mute = StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.videoPlayerMuted, or: false);
    return VideoPlayerMuteState(saved, repo);
  });

  static final blurExplicit =
      StateNotifierProvider<BlurExplicitPostState, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.postBlurExplicit, or: true);
    return BlurExplicitPostState(saved, repo);
  });

  static final loadOriginal =
      StateNotifierProvider<LoadOriginalPostState, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.postLoadOriginal, or: false);
    return LoadOriginalPostState(saved, repo);
  });
}
