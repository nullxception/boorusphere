import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'version.g.dart';

@Riverpod(keepAlive: true)
FutureOr<AppVersion> versionCurrent(VersionCurrentRef ref) {
  final repo = ref.read(versionRepoProvider);
  return repo.get();
}

@Riverpod(keepAlive: true)
FutureOr<AppVersion> versionLatest(VersionLatestRef ref) {
  final repo = ref.read(versionRepoProvider);
  return repo.fetch();
}
