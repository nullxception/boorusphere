import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:boorusphere/utils/file_utils.dart';
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

  Future<void> download(Post post, {String? url}) async {
    final fileUrl = url ?? post.originalFile;
    final targetPath = FileUtils.instance.downloadPath;

    await FileUtils.instance.createDownloadDir();

    final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: targetPath,
        showNotification: true,
        openFileFromNotification: true);

    if (taskId != null) {
      final destination = '$targetPath/${fileUrl.fileName}';
      final entry =
          DownloadEntry(id: taskId, post: post, destination: destination);
      await ref.read(downloadEntryStateProvider.notifier).add(entry);
    }
  }

  Future<void> retry({required String id}) async {
    final newId = await FlutterDownloader.retry(taskId: id);
    if (newId != null) {
      final newEntry = ref
          .read(downloadEntryStateProvider)
          .firstWhere((it) => it.id == id, orElse: DownloadEntry.new)
          .copyWith(id: newId);

      await ref.read(downloadEntryStateProvider.notifier).update(id, newEntry);
    }
  }

  Future<void> cancel({required String id}) async {
    await FlutterDownloader.cancel(taskId: id);
  }

  Future<void> clear({required String id}) async {
    await FlutterDownloader.remove(taskId: id, shouldDeleteContent: false);
    await ref.read(downloadEntryStateProvider.notifier).remove(id);
  }

  void openFile({required String id}) {
    FlutterDownloader.open(taskId: id);
  }
}
