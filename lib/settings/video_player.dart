import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final fromSettings = Settings.videoplayer_mute.read(or: false);
  return VideoPlayerMuteState(fromSettings);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(super.state);

  Future<bool> toggle() async {
    state = !state;
    await Settings.videoplayer_mute.save(state);
    return state;
  }
}
