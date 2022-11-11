import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final devicePropProvider = Provider<DeviceProp>(
    (ref) => throw Exception('DeviceProp must be initialized manually'));

class DeviceProp {
  DeviceProp(this.android);

  final AndroidDeviceInfo android;

  int get sdkVersion => android.version.sdkInt;
}
