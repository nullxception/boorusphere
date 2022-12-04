import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info/package_info.dart';

abstract class EnvRepo {
  PackageInfo get packageInfo;
  AndroidDeviceInfo get androidInfo;
  int get sdkVersion;
}
