import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../hive_boxes.dart';

final _savedBlurExplicitPost = FutureProvider<bool>(
    (ref) async => await BlurExplicitPostState.restore(ref));

final blurExplicitPostProvider =
    StateNotifierProvider<BlurExplicitPostState, bool>((ref) {
  final fromSettings = ref
      .watch(_savedBlurExplicitPost)
      .maybeWhen(data: (data) => data, orElse: () => true);

  return BlurExplicitPostState(ref, fromSettings);
});

class BlurExplicitPostState extends StateNotifier<bool> {
  BlurExplicitPostState(this.ref, initData) : super(initData);

  final Ref ref;

  Future<void> enable(bool value) async {
    state = value;
    final settings = await ref.read(settingsBox);
    settings.put(boxKey, value);
  }

  static Future<bool> restore(FutureProviderRef futureRef) async {
    final settings = await futureRef.read(settingsBox);
    return settings.get(boxKey, defaultValue: true);
  }

  static const boxKey = 'blur_explicit_post';
}
