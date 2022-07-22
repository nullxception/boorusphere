import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedVideoPlayerMute = FutureProvider<bool>(
    (ref) async => await VideoPlayerMuteState.restore(ref));

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final fromSettings = ref
      .read(_savedVideoPlayerMute)
      .maybeWhen(data: (data) => data, orElse: () => false);

  return VideoPlayerMuteState(ref.read, fromSettings);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(this.read, bool initState) : super(initState);

  final Reader read;

  Future<void> toggle() async {
    final newState = !state;
    state = newState;
    final settings = await read(settingsBox);
    settings.put(boxKey, newState);
  }

  static const boxKey = 'videoplayer_mute';

  static Future<bool> restore(FutureProviderRef<bool> ref) async {
    final settings = await ref.read(settingsBox);
    return settings.get(VideoPlayerMuteState.boxKey, defaultValue: false);
  }
}
