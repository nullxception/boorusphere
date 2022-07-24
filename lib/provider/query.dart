import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_query.dart';
import 'search_history_manager.dart';
import 'settings/safe_mode.dart';

final queryProvider = StateNotifierProvider<QueryState, ServerQuery>((ref) {
  final safeMode = ref.watch(safeModeProvider);
  return QueryState(ref, ServerQuery(safeMode: safeMode));
});

class QueryState extends StateNotifier<ServerQuery> {
  QueryState(this.ref, ServerQuery initState) : super(initState);

  final Ref ref;

  Future<void> setTag({required String query}) async {
    final searchHistory = ref.read(searchHistoryProvider);
    if (state.tags != query) {
      state = state.copyWith(tags: query);
      searchHistory.push(query);
    }
  }

  Future<void> setSafeMode(enabled) async {
    if (state.safeMode != enabled) {
      state = state.copyWith(safeMode: enabled);
      final safeModeNotifier = ref.read(safeModeProvider.notifier);
      safeModeNotifier.enable(enabled);
    }
  }
}
