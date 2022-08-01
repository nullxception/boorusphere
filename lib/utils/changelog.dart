import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../providers/app_version.dart';
import 'retry_future.dart';

class ChangelogUtils {
  static Future<String> allFromAssets() async {
    return await rootBundle.loadString(fileName);
  }

  static Future<String> allFromGit() async {
    final res = await retryFuture(
      () => http.get(Uri.parse(url)).timeout(const Duration(seconds: 5)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    return res.body.contains('## 1') ? res.body : '';
  }

  static Future<String> latestFromAssets() async {
    final data = await allFromAssets();
    return getLatest(data);
  }

  static Future<String> latestFromGit() async {
    final data = await allFromGit();
    return getLatest(data);
  }

  static String getLatest(String data) {
    final logs = data.split(RegExp(r'## ([.0-9]+)'));
    return logs.isEmpty ? '' : logs[1];
  }

  static const fileName = 'CHANGELOG.md';
  static const url = '${AppVersionManager.gitUrl}/raw/main/CHANGELOG.md';
}
