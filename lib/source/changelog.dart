import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entity/app_version.dart';
import '../entity/changelog_data.dart';
import '../services/http.dart';
import 'version.dart';

final _dataSourceProvider = Provider(ChangelogDataSource.new);

final changelogProvider =
    FutureProvider.family<List<ChangelogData>, ChangelogOption>(
        (ref, arg) async {
  final dataSource = ref.watch(_dataSourceProvider);
  final rawString = await dataSource.from(arg.type);
  final parsed = await compute(ChangelogData.fromString, rawString);
  if (arg.version != null) {
    return [
      parsed.firstWhere(
        (it) => it.version == arg.version,
        orElse: () => ChangelogData.empty,
      )
    ];
  }
  return parsed;
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
    final res = await client.get(url);
    final data = res.data;
    return data is String && data.contains('## 1') ? data : '';
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
