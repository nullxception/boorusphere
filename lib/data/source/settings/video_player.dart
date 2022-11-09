import 'package:boorusphere/data/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final fromSettings = Settings.videoPlayerMuted.read(or: false);
  return VideoPlayerMuteState(fromSettings);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(super.state);

  Future<bool> toggle() async {
    state = !state;
    await Settings.videoPlayerMuted.save(state);
    return state;
  }
}
