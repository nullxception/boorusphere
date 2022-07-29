import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _androidInfo =
    FutureProvider((ref) async => await DeviceInfoPlugin().androidInfo);

final deviceInfoProvider = Provider((ref) => ref.watch(_androidInfo).maybeWhen(
      data: (info) => DeviceInfo(ref, info),
      orElse: () => DeviceInfo.fromMap(ref, {}),
    ));

class DeviceInfo {
  DeviceInfo(Ref ref, this.androidInfo);

  factory DeviceInfo.fromMap(Ref ref, Map<String, dynamic> mappedInfo) {
    final info = AndroidDeviceInfo.fromMap(mappedInfo);
    return DeviceInfo(ref, info);
  }

  final AndroidDeviceInfo androidInfo;

  int get sdkInt => androidInfo.version.sdkInt ?? 0;
  List<String> get abis =>
      List.from(androidInfo.supportedAbis.whereType<String>());
}
