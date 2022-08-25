import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

final blurExplicitPostProvider =
    StateNotifierProvider<BlurExplicitPostState, bool>((ref) {
  final saved = Settings.postBlurExplicit.read(or: true);
  return BlurExplicitPostState(saved);
});

class BlurExplicitPostState extends StateNotifier<bool> {
  BlurExplicitPostState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.postBlurExplicit.save(value);
  }
}
