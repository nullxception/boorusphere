import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../entity/changelog_data.dart';
import '../utils/retry_future.dart';
import 'version.dart';

final changelogProvider =
    FutureProvider.family<List<ChangelogData>, ChangelogOption>(
        (ref, arg) async {
  final data = await ChangelogDataSource.from(arg.type);
  return ChangelogData.fromString(data);
});

enum ChangelogType {
  assets,
  git,
}

class ChangelogOption {
  const ChangelogOption({
    required this.type,
    this.latestOnly = false,
  });
  final ChangelogType type;
  final bool latestOnly;
}

class ChangelogDataSource {
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

  static const fileName = 'CHANGELOG.md';
  static const url = '${VersionDataSource.gitUrl}/raw/main/CHANGELOG.md';
}
