import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/download/entity/downloads.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'downloader.g.dart';

@riverpod
Downloader downloader(DownloaderRef ref) {
  return Downloader(ref);
}

class Downloader {
  Downloader(this.ref);

  final Ref ref;

  Downloads get state => ref.read(downloadStateProvider);
  DownloadState get stateNotifier => ref.read(downloadStateProvider.notifier);

  Future<void> download(Post post, {String? url}) async {
    final fileUrl = url ?? post.originalFile;
    final dir = await DownloadUtils.downloadDir;

    await DownloadUtils.createDownloadDir();

    final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: dir.absolute.path,
        showNotification: true,
        openFileFromNotification: true);

    if (taskId != null) {
      final destination = '${dir.absolute.path}/${fileUrl.fileName}';
      final entry =
          DownloadEntry(id: taskId, post: post, destination: destination);
      await stateNotifier.add(entry);
    }
  }

  Future<void> retry({required String id}) async {
    final newId = await FlutterDownloader.retry(taskId: id);
    if (newId != null) {
      final newEntry = state.entries
          .firstWhere((it) => it.id == id, orElse: () => DownloadEntry.empty)
          .copyWith(id: newId);

      await stateNotifier.update(id, newEntry);
    }
  }

  Future<void> cancel({required String id}) async {
    await FlutterDownloader.cancel(taskId: id);
  }

  Future<void> clear({required String id}) async {
    await FlutterDownloader.remove(taskId: id, shouldDeleteContent: false);
    await stateNotifier.remove(id);
  }

  void openFile({required String id}) {
    FlutterDownloader.open(taskId: id);
  }
}
