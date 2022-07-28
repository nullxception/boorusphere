import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final blurExplicitPostProvider =
    StateNotifierProvider<BlurExplicitPostState, bool>((ref) {
  final box = Hive.box('settings');
  final fromSettings =
      box.get(BlurExplicitPostState.boxKey, defaultValue: true);
  return BlurExplicitPostState(ref, fromSettings);
});

class BlurExplicitPostState extends StateNotifier<bool> {
  BlurExplicitPostState(this.ref, initData) : super(initData);

  final Ref ref;

  void enable(bool value) {
    state = value;
    Hive.box('settings').put(boxKey, value);
  }

  static const boxKey = 'blur_explicit_post';
}
