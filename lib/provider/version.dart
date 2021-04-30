import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

class VersionState extends ChangeNotifier {
  final Reader read;
  String version = '0.0.0';
  String lastestVersion = '0.0.0';

  get downloadUrl => '$releaseUrl/tag/$lastestVersion';
  get shouldUpdate => version != lastestVersion;

  VersionState(this.read) {
    _init();
  }

  void _init() async {
    final info = await PackageInfo.fromPlatform();
    version = '${info.version}+${info.buildNumber}';
    lastestVersion = '${info.version}+${info.buildNumber}';
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), checkForUpdates);
  }

  void checkForUpdates() async {
    try {
      final res = await http.get(Uri.parse(pubspecUrl));
      if (res.statusCode == 200) {
        final version = loadYaml(res.body)['version'];
        if (version is String && version.contains('+')) {
          lastestVersion = version;
          notifyListeners();
        }
      }
    } on HttpException catch (e) {
      Fimber.d('Caught a network exception', ex: e);
    } on SocketException catch (e) {
      Fimber.d('Caught a network exception', ex: e);
    }
  }

  static const pubspecUrl =
      'https://raw.githubusercontent.com/nullxception/boorusphere/main/pubspec.yaml';
  static const releaseUrl =
      'https://github.com/nullxception/boorusphere/releases';
}
