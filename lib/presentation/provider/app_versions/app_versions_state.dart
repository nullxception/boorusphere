import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_versions_state.g.dart';

typedef AppVersions = ({AppVersion current, AppVersion latest});

@riverpod
class AppVersionsState extends _$AppVersionsState {
  @override
  Future<AppVersions> build() async {
    ref.onDispose(() {
      state = const AsyncValue.loading();
    });
    final repo = ref.read(versionRepoProvider);
    return (
      current: repo.current,
      latest: await repo.fetch(),
    );
  }
}
