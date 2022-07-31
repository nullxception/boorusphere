import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/settings.dart';

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final fromSettings = Settings.videoplayer_mute.read(or: false);
  return VideoPlayerMuteState(fromSettings);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(bool initState) : super(initState);

  bool toggle() {
    final result = !state;
    state = result;
    Settings.videoplayer_mute.save(result);
    return result;
  }
}
