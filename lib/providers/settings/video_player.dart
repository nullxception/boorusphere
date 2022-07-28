import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final box = Hive.box('settings');
  final fromSettings =
      box.get(VideoPlayerMuteState.boxKey, defaultValue: false);
  return VideoPlayerMuteState(ref, fromSettings);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(this.ref, bool initState) : super(initState);

  final Ref ref;

  bool toggle() {
    final result = !state;
    state = result;
    Hive.box('settings').put(boxKey, result);
    return result;
  }

  static const boxKey = 'videoplayer_mute';
}
