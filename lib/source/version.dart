import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

import '../entity/app_version.dart';
import '../services/http.dart';
import '../utils/extensions/string.dart';

final versionCurrentProvider = FutureProvider((ref) async {
  final pkgInfo = await PackageInfo.fromPlatform();
  return AppVersion.fromString(pkgInfo.version);
});

final versionLatestProvider = FutureProvider((ref) {
  final http = ref.read(httpProvider);
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

  static Future<AppVersion> checkLatest(http.Client client) async {
    final res = await client.get(pubspecUrl.asUri);
    if (res.statusCode == 200) {
      final version = loadYaml(res.body)['version'];
      if (version is String && version.contains('+')) {
        return AppVersion.fromString(version);
      }
    }

    return AppVersion.zero;
  }

  static const gitUrl = 'https://github.com/nullxception/boorusphere';
  static const pubspecUrl = '$gitUrl/raw/main/pubspec.yaml';
}
