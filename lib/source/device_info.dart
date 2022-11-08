import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _androidInfo =
    FutureProvider((ref) async => await DeviceInfoPlugin().androidInfo);

final deviceInfoProvider = Provider((ref) => ref.watch(_androidInfo).maybeWhen(
      data: (info) => DeviceInfoSource(ref, info),
      orElse: () => DeviceInfoSource.fromMap(ref, {}),
    ));

class DeviceInfoSource {
  DeviceInfoSource(Ref ref, this.androidInfo);

  factory DeviceInfoSource.fromMap(Ref ref, Map<String, dynamic> mappedInfo) {
    final info = AndroidDeviceInfo.fromMap(mappedInfo);
    return DeviceInfoSource(ref, info);
  }

  final AndroidDeviceInfo androidInfo;

  int get sdkInt => androidInfo.version.sdkInt;
}
