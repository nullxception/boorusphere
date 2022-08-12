import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

import '../../utils/extensions/string.dart';
import '../entity/app_update_data.dart';
import '../entity/app_version.dart';
import '../services/http.dart';

final versionDataProvider = ChangeNotifierProvider(VersionDataSource.new);

final versionUpdateProvider = FutureProvider((ref) async {
  final versionData = ref.watch(versionDataProvider);
  return await versionData._checkForUpdate();
});

class VersionDataSource extends ChangeNotifier {
  VersionDataSource(this.ref) {
    _init();
  }
  final Ref ref;

  AppVersion _version = AppVersion.zero;

  AppVersion get version => _version;

  String get arch {
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

  Future<void> _init() async {
    final pkg = await PackageInfo.fromPlatform();
    _version = AppVersion.fromString(pkg.version);
    notifyListeners();
  }

  Future<AppUpdateData> _checkForUpdate() async {
    AppVersion latest = _version;
    final client = ref.read(httpProvider);
    final res = await client.get(pubspecUrl.asUri);
    if (res.statusCode == 200) {
      final version = loadYaml(res.body)['version'];
      if (version is String && version.contains('+')) {
        latest = AppVersion.fromString(version);
      }
    }

    return AppUpdateData(
      arch: arch,
      currentVersion: _version,
      newVersion: latest,
      apkUrl: '$gitUrl/releases/download/$latest/boorusphere-$latest-$arch.apk',
    );
  }

  static const gitUrl = 'https://github.com/nullxception/boorusphere';
  static const pubspecUrl = '$gitUrl/raw/main/pubspec.yaml';
}
