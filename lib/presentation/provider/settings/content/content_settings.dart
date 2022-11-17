import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/content/blur_explicit.dart';
import 'package:boorusphere/presentation/provider/settings/content/load_original.dart';
import 'package:boorusphere/presentation/provider/settings/content/video_player.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ContentSettingsProvider {
  static final mute =
      StateNotifierProvider<VideoPlayerMuteSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.videoPlayerMuted, or: false);
    return VideoPlayerMuteSettingNotifier(saved, repo);
  });

  static final blurExplicit =
      StateNotifierProvider<BlurExplicitPostSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.postBlurExplicit, or: true);
    return BlurExplicitPostSettingNotifier(saved, repo);
  });

  static final loadOriginal =
      StateNotifierProvider<LoadOriginalPostSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.postLoadOriginal, or: false);
    return LoadOriginalPostSettingNotifier(saved, repo);
  });
}
