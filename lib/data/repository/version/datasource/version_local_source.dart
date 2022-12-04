import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';

class VersionLocalSource {
  VersionLocalSource(this.envRepo);
  final EnvRepo envRepo;

  AppVersion get() {
    return AppVersion.fromString(envRepo.packageInfo.version);
  }
}
