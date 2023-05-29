import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';

abstract interface class SearchHistoryRepo {
  Map<int, SearchHistory> get all;
  Future<void> save(String value, String serverId);
  Future<void> delete(key);
  Future<void> clear();
}
