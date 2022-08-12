import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entity/app_version.dart';
import '../entity/changelog_data.dart';
import '../services/http.dart';
import '../utils/retry_future.dart';
import 'version.dart';

final _dataSourceProvider = Provider(ChangelogDataSource.new);

final changelogProvider =
    FutureProvider.family<List<ChangelogData>, ChangelogOption>(
        (ref, arg) async {
  final dataSource = ref.watch(_dataSourceProvider);
  final data = await dataSource.from(arg.type);
  return ChangelogData.fromString(data);
});

enum ChangelogType {
  assets,
  git,
}

class ChangelogOption {
  const ChangelogOption({
    required this.type,
    this.version,
  });
  final ChangelogType type;
  final AppVersion? version;
}

class ChangelogDataSource {
  ChangelogDataSource(this.ref);

  final Ref ref;

  Future<String> _loadFromAssets() async {
    return await rootBundle.loadString(fileName);
  }

  Future<String> _fetchFromGit() async {
    final client = ref.read(httpProvider);
    final res = await retryFuture(
      () => client.get(Uri.parse(url)).timeout(const Duration(seconds: 5)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    return res.body.contains('## 1') ? res.body : '';
  }

  Future<String> from(ChangelogType type) async {
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
