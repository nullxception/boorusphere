import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../providers/app_version.dart';
import 'retry_future.dart';

enum ChangelogType {
  assets,
  git,
}

class ChangelogUtils {
  static Future<String> _loadFromAssets() async {
    return await rootBundle.loadString(fileName);
  }

  static Future<String> _fetchFromGit() async {
    final res = await retryFuture(
      () => http.get(Uri.parse(url)).timeout(const Duration(seconds: 5)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    return res.body.contains('## 1') ? res.body : '';
  }

  static Future<String> from(ChangelogType type) async {
    String data;
    switch (type) {
      case ChangelogType.git:
        data = await _fetchFromGit();
        break;
      default:
        data = await _loadFromAssets();
        break;
    }

    return data;
  }

  static String getLatest(String data) {
    final logs = data.split(RegExp(r'## ([.0-9]+)'));
    return logs.isEmpty ? '' : logs[1];
  }

  static const fileName = 'CHANGELOG.md';
  static const url = '${AppVersionManager.gitUrl}/raw/main/CHANGELOG.md';
}
