import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:boorusphere/presentation/provider/app_versions/entity/app_versions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_versions_state.g.dart';

@riverpod
class AppVersionsState extends _$AppVersionsState {
  late VersionRepo repo;
  @override
  Future<AppVersions> build() async {
    ref.onDispose(() {
      state = const AsyncValue.loading();
    });
    repo = ref.read(versionRepoProvider);
    return AppVersions(
      current: await repo.get(),
      latest: await repo.fetch(),
    );
  }
}
