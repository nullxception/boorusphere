import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/settings.dart';

final serverPostLimitProvider =
    StateNotifierProvider<ServerPostLimitState, int>((ref) {
  final fromSettings =
      Settings.server_post_limit.read(or: ServerPostLimitState.defaultLimit);
  return ServerPostLimitState(fromSettings);
});

class ServerPostLimitState extends StateNotifier<int> {
  ServerPostLimitState(int initData) : super(initData);

  void save(int value) {
    state = value;
    Settings.server_post_limit.save(value);
  }

  static const defaultLimit = 40;
}
