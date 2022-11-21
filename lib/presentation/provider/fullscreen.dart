import 'package:boorusphere/presentation/provider/device_prop.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fullscreen.g.dart';

@riverpod
class FullscreenState extends _$FullscreenState {
  late List<DeviceOrientation> lastOrientations;

  @override
  bool build() {
    ref.onDispose(() {
      SystemChrome.setPreferredOrientations([]);
      unfullscreen();
    });
    lastOrientations = [];
    return false;
  }

  Future<void> toggle({bool shouldLandscape = false}) async {
    state = !state;
    final orientations = state && shouldLandscape
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : <DeviceOrientation>[];

    if (orientations != lastOrientations) {
      lastOrientations = orientations;
      await SystemChrome.setPreferredOrientations(orientations);
    }

    state
        ? await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
        : await unfullscreen();
  }

  Future<void> unfullscreen() async {
    final deviceProp = ref.read(devicePropProvider);
    if (deviceProp.sdkVersion < 29) {
      // SDK 28 and below ignores edgeToEdge, so we have to manually reenable them
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
