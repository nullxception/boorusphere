import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

class VersionRepoImpl implements VersionRepo {
  VersionRepoImpl({required this.envRepo, required this.client});

  final EnvRepo envRepo;
  final Dio client;

  @override
  AppVersion get current => envRepo.appVersion;

  @override
  Future<AppVersion> fetch() async {
    final res = await client.get(pubspecUrl);
    final data = res.data;
    if (res.statusCode == 200 && data is String && data.contains('version:')) {
      final version = loadYaml(data)['version'];
      if (version is String && version.contains('+')) {
        return AppVersion.fromString(version);
      }
    }

    return AppVersion.zero;
  }

  static const gitUrl = 'https://github.com/nullxception/boorusphere';
  static const pubspecUrl = '$gitUrl/raw/main/pubspec.yaml';
}
