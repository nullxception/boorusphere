import 'package:hive/hive.dart';

part 'search_history.g.dart';

@HiveType(typeId: 1, adapterName: 'SearchHistoryAdapter')
class SearchHistory {
  const SearchHistory({
    this.query = '*',
    this.server = '',
  });

  @HiveField(0, defaultValue: '')
  final String query;
  @HiveField(1, defaultValue: '')
  final String server;

  @override
  bool operator ==(covariant SearchHistory other) {
    if (identical(this, other)) return true;

    return other.query == query && other.server == server;
  }

  @override
  int get hashCode => query.hashCode ^ server.hashCode;
}
