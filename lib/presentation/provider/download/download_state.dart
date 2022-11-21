import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/download_repo.dart';
import 'package:boorusphere/presentation/provider/download/entity/downloads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_state.g.dart';

@riverpod
class DownloadState extends _$DownloadState {
  late DownloadRepo repo;

  @override
  Downloads build() {
    repo = ref.watch(downloadRepoProvider);
    Future(_populate);
    return const Downloads();
  }

  Future<void> _populate() async {
    state = Downloads(
      entries: repo.getEntries().toList(),
      progresses: (await repo.getProgress()).toSet(),
    );
  }

  Future<void> add(DownloadEntry entry) async {
    await repo.add(entry);
    state = state.copyWith(entries: [
      ...state.entries.where((it) => it.id != entry.id),
      entry,
    ]);
  }

  Future<void> remove(String id) async {
    await repo.remove(id);
    state = state.copyWith(
      entries: state.entries.where((it) => it.id != id).toList(),
      progresses: state.progresses.where((it) => it.id != id).toSet(),
    );
  }

  Future<void> update(String id, DownloadEntry entry) async {
    await repo.remove(id);
    await repo.add(entry);
    state = state.copyWith(
      entries: [
        ...state.entries.where((it) => it.id != entry.id),
        entry,
      ],
      progresses: state.progresses
          .where((it) => it.id != id && it.id != entry.id)
          .toSet(),
    );
  }

  updateProgress(DownloadProgress progress) {
    state = state.copyWith(
      progresses: {
        ...state.progresses.where((it) => it.id != progress.id),
        progress
      },
    );
  }

  Future<void> clear() async {
    await repo.clear();
    state = const Downloads();
  }
}
