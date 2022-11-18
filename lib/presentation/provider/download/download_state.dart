import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/download_repo.dart';
import 'package:boorusphere/presentation/provider/download/entity/downloads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_state.g.dart';

@riverpod
class DownloadState extends _$DownloadState {
  final entries = <DownloadEntry>[];
  final progresses = <DownloadProgress>{};
  late DownloadRepo repo;

  @override
  Downloads build() {
    repo = ref.watch(downloadRepoProvider);
    Future(_populate);
    return const Downloads();
  }

  Future<void> _populate() async {
    entries.addAll(repo.getEntries());
    progresses.addAll(await repo.getProgress());
    state = Downloads(entries: entries, progresses: progresses);
  }

  Future<void> add(DownloadEntry entry) async {
    entries.removeWhere((it) => it.id == entry.id);
    entries.add(entry);
    await repo.add(entry);
    state = Downloads(entries: entries, progresses: progresses);
  }

  Future<void> remove(String id) async {
    progresses.removeWhere((it) => it.id == id);
    entries.removeWhere((it) => it.id == id);
    await repo.remove(id);
    state = Downloads(entries: entries, progresses: progresses);
  }

  Future<void> update(String id, DownloadEntry entry) async {
    progresses.removeWhere((it) => it.id == id);
    entries.removeWhere((it) => it.id == id || it.id == entry.id);
    await repo.remove(id);

    entries.add(entry);
    await repo.add(entry);
    state = Downloads(entries: entries, progresses: progresses);
  }

  updateProgress(DownloadProgress progress) {
    progresses.removeWhere((it) => it.id == progress.id);
    progresses.add(progress);
    state = Downloads(entries: entries, progresses: progresses);
  }

  Future<void> clear() async {
    progresses.clear();
    entries.clear();
    await repo.clear();
    state = Downloads(entries: entries, progresses: progresses);
  }
}
