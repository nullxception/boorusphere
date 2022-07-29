import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_info.dart';

final fullscreenProvider =
    StateNotifierProvider.autoDispose<FullscreenManager, bool>((ref) {
  return FullscreenManager(ref);
});

class FullscreenManager extends StateNotifier<bool> {
  FullscreenManager(this.ref) : super(false);

  final Ref ref;
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

    state
        ? await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
        : await unfullscreen();
  }

  Future<void> unfullscreen() async {
    final info = ref.read(deviceInfoProvider);
    if (info.sdkInt < 29) {
      // SDK 28 and below ignores edgeToEdge, so we have to manually reenable them
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    unfullscreen();
    super.dispose();
  }
}
