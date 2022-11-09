import 'package:boorusphere/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadOriginalPostProvider =
    StateNotifierProvider<LoadOriginalPostState, bool>((ref) {
  final saved = Settings.postLoadOriginal.read(or: false);
  return LoadOriginalPostState(saved);
});

class LoadOriginalPostState extends StateNotifier<bool> {
  LoadOriginalPostState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.postLoadOriginal.save(value);
  }
}
