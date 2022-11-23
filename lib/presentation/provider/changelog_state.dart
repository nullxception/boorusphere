import 'package:boorusphere/data/repository/changelog/entity/changelog_data.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'changelog_state.g.dart';

enum ChangelogType {
  assets,
  git;

  bool get onGit => this == git;
}

@riverpod
class ChangelogState extends _$ChangelogState {
  late ChangelogRepo _repo;

  @override
  Future<List<ChangelogData>> build(
    ChangelogType type,
    AppVersion? version,
  ) async {
    _repo = ref.watch(changelogRepoProvider);
    final res = type.onGit ? await _repo.fetch() : await _repo.get();
    return _parseResult(res);
  }

  Future<List<ChangelogData>> _parseResult(String data) async {
    final parsed = await compute(ChangelogData.fromString, data);

    if (version != null) {
      return [
        parsed.firstWhere(
          (it) => it.version == version,
          orElse: () => ChangelogData.empty,
        )
      ];
    } else {
      return parsed;
    }
  }
}
