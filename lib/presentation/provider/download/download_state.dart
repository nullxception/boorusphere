import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/download/entity/download_item.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_state.g.dart';

@Riverpod(keepAlive: true)
class DownloadState extends _$DownloadState {
  @override
  Iterable<DownloadItem> build() {
    // populate later
    return [];
  }

  Future<void> populate() async {
    final repo = ref.read(downloadRepoProvider);
    final progresses = repo.getProgresses();
    state = repo.getEntries().map(
          (entry) => DownloadItem(
            entry: entry,
            progress: progresses.firstWhere(
              (it) => it.id == entry.id,
              orElse: () => DownloadProgress.none,
            ),
          ),
        );
  }

  Future<void> add(DownloadEntry entry) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.add(entry);
    state = [
      ...state.where((it) => it.entry.id != entry.id),
      DownloadItem(entry: entry),
    ];
  }

  Future<void> remove(String id) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.remove(id);
    state = [...state.where((it) => it.entry.id != id)];
  }

  Future<void> update(String id, DownloadEntry entry) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.remove(id);
    await repo.add(entry);
    state = [
      ...state.where((it) => it.entry.id != id),
      DownloadItem(entry: entry),
    ];
  }

  Future<void> updateProgress(DownloadProgress progress) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.updateProgress(progress);
    final item = state.singleWhereOrNull((it) => it.entry.id == progress.id);
    state = [
      ...state.where((it) => it.entry.id != progress.id),
      if (item != null) item.copyWith(progress: progress)
    ];
  }

  Future<void> clear() async {
    final repo = ref.read(downloadRepoProvider);
    await repo.clear();
    state = [];
  }
}

extension DownloadItemsExt on Iterable<DownloadItem> {
  DownloadProgress getProgressById(String id) {
    final item = firstWhereOrNull((it) => it.entry.id == id);
    return item?.progress ?? DownloadProgress.none;
  }

  DownloadProgress getProgressByPost(Post post) {
    final item = firstWhereOrNull((it) => it.entry.post == post);
    return item?.progress ?? DownloadProgress.none;
  }

  Iterable<DownloadItem> whereNotReserved() {
    return whereNot((it) => it.entry.post == Post.appReserved);
  }
}
