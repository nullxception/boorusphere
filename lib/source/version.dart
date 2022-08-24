import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

import '../entity/app_version.dart';
import '../services/http.dart';

final versionCurrentProvider = FutureProvider((ref) async {
  final pkgInfo = await PackageInfo.fromPlatform();
  return AppVersion.fromString(pkgInfo.version);
});

final versionLatestProvider = FutureProvider((ref) {
  final http = ref.watch(httpProvider);
  return VersionDataSource.checkLatest(http);
});

class VersionDataSource {
  static String get arch {
    switch (Abi.current()) {
      case Abi.androidX64:
        return 'x86_64';
      case Abi.androidArm64:
        return 'arm64-v8a';
      // we have no x86 apk, so most likely we're running in arm emulation mode
      case Abi.androidIA32:
      case Abi.androidArm:
        return 'armeabi-v7a';
      default:
        return Abi.current().toString();
    }
  }

  static Future<AppVersion> checkLatest(Dio client) async {
    final res = await client.get(pubspecUrl);
    final data = res.data;
    if (res.statusCode == 200 && data is String) {
      final version = loadYaml(data)['version'];
      if (version is String && version.contains('+')) {
        return AppVersion.fromString(version);
      }
    }

    return AppVersion.zero;
  }

  static const gitUrl = 'https://github.com/nullxception/boorusphere';
  static const pubspecUrl = '$gitUrl/raw/main/pubspec.yaml';
}
