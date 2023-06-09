import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/pigeon/app_env.pi.dart';

abstract interface class EnvRepo {
  Env get env;
  int get sdkVersion;
  AppVersion get appVersion;
}
