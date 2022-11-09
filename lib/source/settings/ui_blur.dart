import 'package:boorusphere/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uiBlurProvider = StateNotifierProvider<UIBlurState, bool>((ref) {
  final saved = Settings.uiBlur.read(or: false);
  return UIBlurState(saved);
});

class UIBlurState extends StateNotifier<bool> {
  UIBlurState(super.state);

  Future<bool> enable(bool value) async {
    state = value;
    await Settings.uiBlur.save(value);
    return state;
  }
}
