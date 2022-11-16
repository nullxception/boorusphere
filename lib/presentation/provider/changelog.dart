import 'package:boorusphere/data/repository/changelog/entity/changelog_data.dart';
import 'package:boorusphere/data/repository/changelog/entity/changelog_option.dart';
import 'package:boorusphere/data/repository/changelog/entity/changelog_type.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/changelog_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changelogProvider = Provider.autoDispose((ref) {
  return ChangelogNotifier(ref.watch(changelogRepoProvider));
});

final changelogDataProvider =
    FutureProvider.family<List<ChangelogData>, ChangelogOption>((ref, arg) {
  return ref.read(changelogProvider).invoke(arg);
});

class ChangelogNotifier {
  ChangelogNotifier(this.repo);

  final ChangelogRepo repo;

  Future<List<ChangelogData>> invoke(ChangelogOption arg) async {
    String data;
    switch (arg.type) {
      case ChangelogType.git:
        data = await repo.get();
        break;
      default:
        data = await repo.fetch();
        break;
    }

    final parsed = await compute(ChangelogData.fromString, data);

    if (arg.version != null) {
      return [
        parsed.firstWhere(
          (it) => it.version == arg.version,
          orElse: () => ChangelogData.empty,
        )
      ];
    }

    return parsed;
  }
}
