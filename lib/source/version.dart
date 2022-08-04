import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

import '../../utils/extensions/string.dart';
import '../entity/app_update_data.dart';
import '../entity/app_version.dart';
import 'device_info.dart';

final versionDataProvider =
    ChangeNotifierProvider((ref) => VersionDataSource(ref));

final versionUpdateProvider = FutureProvider((ref) async {
  final versionData = ref.watch(versionDataProvider);
  return await versionData._checkForUpdate();
});

class VersionDataSource extends ChangeNotifier {
  final Ref ref;

  AppVersion _version = AppVersion.zero;

  AppVersion get version => _version;
  String get arch => ref.read(deviceInfoProvider).guessCompatibleAbi();

  VersionDataSource(this.ref) {
    _init();
  }

  void _init() async {
    final pkg = await PackageInfo.fromPlatform();
    _version = AppVersion.fromString(pkg.version);
    notifyListeners();
  }

  Future<AppUpdateData> _checkForUpdate() async {
    AppVersion latest = _version;
    final res = await http.get(pubspecUrl.asUri);
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
