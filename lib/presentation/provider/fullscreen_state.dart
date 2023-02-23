import 'package:boorusphere/domain/provider.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fullscreen_state.g.dart';

@riverpod
class FullscreenState extends _$FullscreenState {
  List<DeviceOrientation> _lastOrientations = [];

  @override
  bool build() {
    ref.onDispose(reset);
    _lastOrientations = [];
    return false;
  }

  Future<void> toggle({bool shouldLandscape = false}) async {
    state = !state;
    final orientations = state && shouldLandscape
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : <DeviceOrientation>[];

    if (orientations != _lastOrientations) {
      _lastOrientations = orientations;
      await SystemChrome.setPreferredOrientations(orientations);
    }

    state
        ? await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
        : await unfullscreen();
  }

  Future<void> unfullscreen() async {
    final envRepo = ref.read(envRepoProvider);
    if (envRepo.sdkVersion < 29) {
      // SDK 28 and below ignores edgeToEdge, so we have to manually reenable them
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void reset() {
    SystemChrome.setPreferredOrientations([]);
    unfullscreen();
  }
}
