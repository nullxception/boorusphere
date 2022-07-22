import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedBlurExplicitPost = FutureProvider<bool>(
    (ref) async => await BlurExplicitPostState.restore(ref));

final blurExplicitPostProvider =
    StateNotifierProvider<BlurExplicitPostState, bool>((ref) {
  final fromSettings = ref
      .read(_savedBlurExplicitPost)
      .maybeWhen(data: (data) => data, orElse: () => true);

  return BlurExplicitPostState(ref.read, fromSettings);
});

class BlurExplicitPostState extends StateNotifier<bool> {
  BlurExplicitPostState(this.read, initData) : super(initData);

  final Reader read;

  Future<void> enable(bool value) async {
    state = value;
    final settings = await read(settingsBox);
    settings.put(boxKey, value);
  }

  static Future<bool> restore(FutureProviderRef ref) async {
    final settings = await ref.read(settingsBox);
    return settings.get(BlurExplicitPostState.boxKey) ?? true;
  }

  static const boxKey = 'blur_explicit_post';
}
