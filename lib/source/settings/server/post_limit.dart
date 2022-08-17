import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings.dart';

final serverPostLimitProvider =
    StateNotifierProvider<ServerPostLimitState, int>((ref) {
  final saved =
      Settings.server_post_limit.read(or: ServerPostLimitState.defaultLimit);
  return ServerPostLimitState(saved);
});

class ServerPostLimitState extends StateNotifier<int> {
  ServerPostLimitState(super.state);

  Future<void> update(int value) async {
    state = value;
    await Settings.server_post_limit.save(value);
  }

  static const defaultLimit = 40;
}
