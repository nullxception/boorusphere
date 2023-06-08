import 'package:boorusphere/data/repository/version/version_repo_impl.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class ChangelogRepoImpl implements ChangelogRepo {
  ChangelogRepoImpl({required this.bundle, required this.client});

  final AssetBundle bundle;
  final Dio client;

  @override
  Future<String> get() async {
    return await bundle.loadString(fileName);
  }

  @override
  Future<String> fetch() async {
    final res = await client.get(url);
    final data = res.data;
    return data is String && data.contains(RegExp(r'## [0-9]+\.')) ? data : '';
  }

  static const fileName = 'CHANGELOG.md';
  static const url = '${VersionRepoImpl.gitUrl}/raw/main/CHANGELOG.md';
}
