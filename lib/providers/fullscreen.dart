import 'package:device_info_plus/device_info_plus.dart';
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

    state
        ? await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
        : await unfullscreen();
  }

  Future<void> unfullscreen() async {
    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt ?? 0;
    if (sdkInt < 29) {
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
