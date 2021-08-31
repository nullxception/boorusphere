import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common.dart';

class VideoPlayerState extends ChangeNotifier {
  static const keyMute = 'videoplayer_mute';

  final Reader read;

  bool _mute = false;

  VideoPlayerState(this.read) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await read(settingsBox);
    _mute = prefs.get(keyMute) ?? false;
  }

  get mute => _mute;

  set mute(value) {
    _mute = value;
    read(settingsBox).then((it) => it.put(keyMute, value));
  }
}
