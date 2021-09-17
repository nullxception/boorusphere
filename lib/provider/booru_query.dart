import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_query.dart';
import 'search_history.dart';

class BooruQueryNotifier extends StateNotifier<ServerQuery> {
  BooruQueryNotifier(this.read) : super(const ServerQuery());

  final Reader read;

  Future<void> setTag({required String query}) async {
    final searchHistory = read(searchHistoryProvider);
    if (state.tags != query) {
      state = state.copyWith(tags: query);
      searchHistory.push(query);
    }
  }
}

final booruQueryProvider =
    StateNotifierProvider<BooruQueryNotifier, ServerQuery>(
        (ref) => BooruQueryNotifier(ref.read));
