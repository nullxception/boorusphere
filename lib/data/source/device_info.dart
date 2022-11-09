import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceInfoProvider = Provider<DeviceInfoSource>(
    (ref) => throw Exception('DeviceInfoSource must be initialized manually'));

class DeviceInfoSource {
  DeviceInfoSource(this.androidInfo);

  final AndroidDeviceInfo androidInfo;

  int get sdkInt => androidInfo.version.sdkInt;
}
