import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

class VersionNetworkSource {
  VersionNetworkSource(this.client);
  final Dio client;

  Future<AppVersion> get() async {
    final res = await client.get(pubspecUrl);
    final data = res.data;
    if (res.statusCode == 200 && data is String) {
      final version = loadYaml(data)['version'];
      if (version is String && version.contains('+')) {
        return AppVersion.fromString(version);
      }
    }

    return AppVersion.zero;
  }

  static const gitUrl = 'https://github.com/asyncmash/boorusphere';
  static const pubspecUrl = '$gitUrl/raw/main/pubspec.yaml';
}
