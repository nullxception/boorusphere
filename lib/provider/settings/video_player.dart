import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedVideoPlayerMute = FutureProvider<bool>(
    (ref) async => await VideoPlayerMuteState.restore(ref));

final videoPlayerMuteProvider =
    StateNotifierProvider<VideoPlayerMuteState, bool>((ref) {
  final fromSettings = ref
      .watch(_savedVideoPlayerMute)
      .maybeWhen(data: (data) => data, orElse: () => false);

  return VideoPlayerMuteState(ref, fromSettings);
});

class VideoPlayerMuteState extends StateNotifier<bool> {
  VideoPlayerMuteState(this.ref, bool initState) : super(initState);

  final Ref ref;

  Future<bool> toggle() async {
    final newState = !state;
    state = newState;
    final settings = await ref.read(settingsBox);
    settings.put(boxKey, newState);
    return newState;
  }

  static const boxKey = 'videoplayer_mute';

  static Future<bool> restore(FutureProviderRef futureRef) async {
    final settings = await futureRef.read(settingsBox);
    return settings.get(VideoPlayerMuteState.boxKey, defaultValue: false);
  }
}
