import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:yaml/yaml.dart';

import '../../utils/extensions/string.dart';
import 'device_info.dart';

final versionDataProvider =
    ChangeNotifierProvider((ref) => VersionDataSource(ref));

class VersionDataSource extends ChangeNotifier {
  final Ref ref;

  String version = '0.0.0';
  String lastestVersion = '0.0.0';
  bool _isChecking = false;
  bool _isChecked = false;
  String _variant = 'armeabi-v7a';

  bool get shouldUpdate => version != lastestVersion;
  bool get isChecking => _isChecking;
  bool get isChecked => _isChecked;

  VersionDataSource(this.ref) {
    _init();
  }

  get variant => _variant;

  void _init() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    lastestVersion = info.version;
    _variant = await guessBestVariant();
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), checkForUpdate);
  }

  Future<String> guessBestVariant() async {
    final info = ref.read(deviceInfoProvider);

    if (info.abis.contains('x86_64')) {
      return 'x86_64';
    } else if (info.abis.contains('arm64-v8a')) {
      return 'arm64-v8a';
    } else {
      return 'armeabi-v7a';
    }
  }

  Future<void> checkForUpdate() async {
    try {
      _isChecking = true;
      notifyListeners();

      final res = await http.get(pubspecUrl.asUri);
      if (res.statusCode == 200) {
        final version = loadYaml(res.body)['version'];
        if (version is String && version.contains('+')) {
          lastestVersion = version.split('+').first;
        }
      }
    } on HttpException catch (e) {
      Fimber.d('Caught a network exception', ex: e);
    } on SocketException catch (e) {
      Fimber.d('Caught a network exception', ex: e);
    }
    _isChecking = false;
    _isChecked = true;
    notifyListeners();
  }

  String get apkUrl {
    return '$releasePageUrl/download/$lastestVersion/boorusphere-$lastestVersion-$_variant.apk';
  }

  static const gitUrl = 'https://github.com/nullxception/boorusphere';
  static const releasePageUrl = '$gitUrl/releases';
  static const pubspecUrl = '$gitUrl/raw/main/pubspec.yaml';
}
