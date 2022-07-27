import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fullscreenProvider =
    StateNotifierProvider.autoDispose<FullscreenManager, bool>((ref) {
  return FullscreenManager();
});

class FullscreenManager extends StateNotifier<bool> {
  FullscreenManager() : super(false);

  final lastOrientations = <DeviceOrientation>[];

  Future<void> toggle({bool shouldLandscape = false}) async {
    state = !state;
    final orientations = state && shouldLandscape
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : <DeviceOrientation>[];

    if (orientations != lastOrientations) {
      lastOrientations
        ..clear()
        ..addAll(orientations);
    }

    if (orientations != lastOrientations) {
      await SystemChrome.setPreferredOrientations(orientations);
    }

    await _fullscreen(state);
  }

  Future<void> _fullscreen(bool isFullscreen) async {
    if (isFullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      // SDK 28 and below ignores edgeToEdge, so we have to manually reenable them
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _fullscreen(false);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }
}
