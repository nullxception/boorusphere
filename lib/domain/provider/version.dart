import 'package:boorusphere/data/provider/dio.dart';
import 'package:boorusphere/data/repository/version/datasource/version_local_source.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/version_repo_impl.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final versionRepoProvider = Provider<VersionRepo>((ref) {
  final http = ref.watch(dioProvider);
  return VersionRepoImpl(
    localSource: VersionLocalSource(),
    networkSource: VersionNetworkSource(http),
  );
});
