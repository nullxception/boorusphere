import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StyleProvider extends ChangeNotifier {
  bool _isFull = false;
  bool _isLandOnly = false;

  bool get isFullScreen => _isFull;
  bool get isForcedLandscape => _isLandOnly;

  setFullScreen({required bool enable, bool notify = true}) {
    if (_isFull == enable) return;

    _isFull = enable;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    if (notify) notifyListeners();
  }

  setForcedLandscape({required bool enable, bool notify = true}) {
    if (_isLandOnly == enable) return;

    _isLandOnly = enable;
    SystemChrome.setPreferredOrientations(
      _isLandOnly
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [],
    );

    if (notify) notifyListeners();
  }

  void resetSystemOverrides({bool notify = true}) {
    if (!(_isLandOnly | _isFull)) return;

    if (_isFull != false) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _isFull = false;
    }
    if (_isLandOnly != false) {
      SystemChrome.setPreferredOrientations([]);
      _isLandOnly = false;
    }

    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    resetSystemOverrides(notify: false);
    super.dispose();
  }
}
