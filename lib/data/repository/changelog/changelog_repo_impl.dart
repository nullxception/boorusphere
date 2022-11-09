import 'package:boorusphere/data/repository/changelog/datasource/changelog_local_source.dart';
import 'package:boorusphere/data/repository/changelog/datasource/changelog_network_source.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';

class ChangelogRepoImpl implements ChangelogRepo {
  ChangelogRepoImpl({required this.localSource, required this.networkSource});

  final ChangelogNetworkSource networkSource;
  final ChangelogLocalSource localSource;

  @override
  Future<String> get() => localSource.load();

  @override
  Future<String> fetch() => networkSource.load();
}
