import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:dio/dio.dart';

class ChangelogNetworkSource {
  ChangelogNetworkSource(this.client);

  final Dio client;

  Future<String> load() async {
    final res = await client.get(url);
    final data = res.data;
    return data is String && data.contains('## 1') ? data : '';
  }

  static const url = '${VersionNetworkSource.gitUrl}/raw/main/CHANGELOG.md';
}
