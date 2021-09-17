import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_query.dart';
import 'hive_boxes.dart';
import 'search_history.dart';

class BooruQueryNotifier extends StateNotifier<ServerQuery> {
  BooruQueryNotifier(this.read) : super(const ServerQuery()) {
    _init();
  }

  final Reader read;

  void _init() async {
    final prefs = await read(settingsBox);
    final enabled = prefs.get('server_safe_mode') ?? true;
    state = state.copyWith(safeMode: enabled);
  }

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
      final prefs = await read(settingsBox);
      prefs.put('server_safe_mode', enabled);
    }
  }
}

final booruQueryProvider =
    StateNotifierProvider<BooruQueryNotifier, ServerQuery>(
        (ref) => BooruQueryNotifier(ref.read));
