import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_prop.g.dart';

@Riverpod(keepAlive: true)
DeviceProp deviceProp(DevicePropRef ref) {
  throw UnimplementedError('DeviceProp must be overridden manually');
}

class DeviceProp {
  DeviceProp(this.android);

  final AndroidDeviceInfo android;

  int get sdkVersion => android.version.sdkInt;
}
