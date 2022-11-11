import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/search_history/search_history_repo_impl.dart';
import 'package:boorusphere/domain/repository/search_history_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final searchHistoryRepoProvider = Provider<SearchHistoryRepo>(
  (ref) => SearchHistoryRepoImpl(
    localSource:
        SearchHistoryLocalSource(Hive.box(SearchHistoryLocalSource.key)),
  ),
);
