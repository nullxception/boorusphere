import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/settings.dart';

final blurExplicitPostProvider =
    StateNotifierProvider<BlurExplicitPostState, bool>((ref) {
  final fromSettings = Settings.blur_explicit_post.read(or: true);
  return BlurExplicitPostState(fromSettings);
});

class BlurExplicitPostState extends StateNotifier<bool> {
  BlurExplicitPostState(super.initData);

  void enable(bool value) {
    state = value;
    Settings.blur_explicit_post.save(value);
  }
}
