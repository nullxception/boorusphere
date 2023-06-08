import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_state.g.dart';

@Riverpod(keepAlive: true)
class DownloadEntryState extends _$DownloadEntryState {
  @override
  Iterable<DownloadEntry> build() {
    final repo = ref.read(downloadsRepoProvider);
    return repo.getEntries();
  }

  Future<void> add(DownloadEntry entry) async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.addEntry(entry);
    state = [
      ...state.where((it) => it.id != entry.id),
      entry,
    ];
  }

  Future<void> remove(String id) async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.removeEntry(id);
    await ref.read(downloadProgressStateProvider.notifier).remove(id);
    state = [...state.where((it) => it.id != id)];
  }

  Future<void> update(String id, DownloadEntry entry) async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.removeEntry(id);
    await repo.addEntry(entry);
    state = [
      ...state.where((it) => it.id != id),
      entry,
    ];
  }

  Future<void> clear() async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.clearEntries();
    await ref.read(downloadProgressStateProvider.notifier).clear();
    state = [];
  }
}

@Riverpod(keepAlive: true)
class DownloadProgressState extends _$DownloadProgressState {
  @override
  Iterable<DownloadProgress> build() {
    final repo = ref.read(downloadsRepoProvider);
    return repo.getProgresses();
  }

  Future<void> update(DownloadProgress progress) async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.updateProgress(progress);
    state = [...state.where((it) => it.id != progress.id), progress];
  }

  Future<void> remove(String id) async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.removeProgress(id);
    state = [...state.where((it) => it.id != id)];
  }

  Future<void> clear() async {
    final repo = ref.read(downloadsRepoProvider);
    await repo.clearProgresses();
    state = [];
  }
}

extension DownloadProgressesExt on Iterable<DownloadProgress> {
  DownloadProgress getById(String id) {
    final item = firstWhereOrNull((x) => x.id == id);
    return item ?? DownloadProgress.none;
  }
}

extension DownloadEntriesExt on Iterable<DownloadEntry> {
  Iterable<DownloadEntry> whereNotReserved() {
    return whereNot((x) => x.post.isReserved);
  }

  DownloadEntry getByPost(Post post) {
    return firstWhere((x) => x.post == post, orElse: () => DownloadEntry.empty);
  }
}
