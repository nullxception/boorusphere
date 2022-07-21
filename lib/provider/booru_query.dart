import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_query.dart';
import 'search_history.dart';
import 'settings/safe_mode.dart';

final booruQueryProvider =
    StateNotifierProvider<BooruQueryNotifier, ServerQuery>((ref) {
  final safeMode = ref.read(safeModeProvider);
  return BooruQueryNotifier(ref.read, ServerQuery(safeMode: safeMode));
});

class BooruQueryNotifier extends StateNotifier<ServerQuery> {
  BooruQueryNotifier(this.read, ServerQuery initState) : super(initState);

  final Reader read;

  Future<void> setTag({required String query}) async {
    final searchHistory = read(searchHistoryProvider);
    if (state.tags != query) {
      state = state.copyWith(tags: query);
      searchHistory.push(query);
    }
  }

  Future<void> setSafeMode(enabled) async {
    if (state.safeMode != enabled) {
      state = state.copyWith(safeMode: enabled);
      final safeModeNotifier = read(safeModeProvider.notifier);
      safeModeNotifier.enable(enabled);
    }
  }
}
