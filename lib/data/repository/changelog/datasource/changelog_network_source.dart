import 'package:boorusphere/data/source/version.dart';
import 'package:dio/dio.dart';

class ChangelogNetworkSource {
  ChangelogNetworkSource(this.client);

  final Dio client;

  Future<String> load() async {
    final res = await client.get(url);
    final data = res.data;
    return data is String && data.contains('## 1') ? data : '';
  }

  static const url = '${VersionDataSource.gitUrl}/raw/main/CHANGELOG.md';
}
