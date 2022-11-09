import 'package:boorusphere/data/repository/changelog/changelog_repo_impl.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_local_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_network_source.dart';
import 'package:boorusphere/data/services/http.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changelogRepoProvider = Provider<ChangelogRepo>((ref) {
  return ChangelogRepoImpl(
    localSource: ChangelogLocalSource(rootBundle),
    networkSource: ChangelogNetworkSource(ref.watch(httpProvider)),
  );
});
