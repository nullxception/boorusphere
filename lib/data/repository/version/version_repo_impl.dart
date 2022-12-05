import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';

class VersionRepoImpl implements VersionRepo {
  VersionRepoImpl({required this.envRepo, required this.networkSource});

  final EnvRepo envRepo;
  final VersionNetworkSource networkSource;

  @override
  AppVersion get current => envRepo.appVersion;

  @override
  Future<AppVersion> fetch() => networkSource.get();
}
