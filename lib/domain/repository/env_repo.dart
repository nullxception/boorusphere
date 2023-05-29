import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info/package_info.dart';

abstract interface class EnvRepo {
  PackageInfo get packageInfo;
  AndroidDeviceInfo get androidInfo;
  int get sdkVersion;
  AppVersion get appVersion;
}
