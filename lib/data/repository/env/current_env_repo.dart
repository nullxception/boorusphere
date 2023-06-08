import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info/package_info.dart';

class CurrentEnvRepo implements EnvRepo {
  CurrentEnvRepo({required this.packageInfo, required this.androidInfo});

  @override
  final PackageInfo packageInfo;

  @override
  final AndroidDeviceInfo androidInfo;

  @override
  int get sdkVersion => androidInfo.version.sdkInt;

  @override
  AppVersion get appVersion => AppVersion.fromString(packageInfo.version);
}
