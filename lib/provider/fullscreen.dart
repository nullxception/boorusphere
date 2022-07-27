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
    final mode = state ? SystemUiMode.immersive : SystemUiMode.edgeToEdge;
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

    await SystemChrome.setEnabledSystemUIMode(mode);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }
}
