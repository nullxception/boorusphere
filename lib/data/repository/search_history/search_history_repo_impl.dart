import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';

class SearchHistoryRepoImpl implements SearchHistoryRepo {
  SearchHistoryRepoImpl({required this.localSource});
  final SearchHistoryLocalSource localSource;

  @override
  Map<int, SearchHistory> get all => localSource.get();

  @override
  Future<void> save(String value, serverId) => localSource.add(value, serverId);

  @override
  Future<void> delete(key) => localSource.delete(key);

  @override
  Future<void> clear() => localSource.clear();
}
