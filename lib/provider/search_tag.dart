import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'common.dart';

class SearchTagState extends StateNotifier<String> {
  SearchTagState(this.read) : super(ServerData.defaultTag);

  final Reader read;

  Future<void> setTag({required String query}) async {
    final searchHistory = read(searchHistoryProvider);
    final tags = query.trim();
    if (state != tags) {
      state = tags;
      searchHistory.push(query);
    }
  }
}
