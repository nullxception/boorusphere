import 'package:boorusphere/source/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  final saved = Settings.serverSafeMode.read(or: true);
  return SafeModeState(saved);
});

class SafeModeState extends StateNotifier<bool> {
  SafeModeState(super.state);

  Future<void> update(bool value) async {
    state = value;
    await Settings.serverSafeMode.save(value);
  }
}
