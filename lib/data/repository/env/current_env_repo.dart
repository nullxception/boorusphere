import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/pigeon/app_env.pi.dart';

class CurrentEnvRepo implements EnvRepo {
  CurrentEnvRepo({required this.env});

  @override
  final Env env;

  @override
  int get sdkVersion => env.sdkVersion;

  @override
  AppVersion get appVersion => AppVersion.fromString(env.versionName);
}
