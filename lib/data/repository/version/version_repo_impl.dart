import 'package:boorusphere/data/repository/version/datasource/version_local_source.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';

class VersionRepoImpl implements VersionRepo {
  VersionRepoImpl({required this.localSource, required this.networkSource});

  final VersionNetworkSource networkSource;
  final VersionLocalSource localSource;

  @override
  AppVersion get() => localSource.get();

  @override
  Future<AppVersion> fetch() => networkSource.get();
}
