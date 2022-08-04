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

  int get sdkInt => androidInfo.version.sdkInt ?? 0;
  List<String> get abis =>
      List.from(androidInfo.supportedAbis.whereType<String>());

  String guessCompatibleAbi() {
    if (abis.contains('x86_64')) {
      return 'x86_64';
    } else if (abis.contains('arm64-v8a')) {
      return 'arm64-v8a';
    } else {
      return 'armeabi-v7a';
    }
  }
}
