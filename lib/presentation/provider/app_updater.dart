import 'dart:io';

import 'package:boorusphere/constant/app.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';
import 'package:boorusphere/data/repository/version/app_version_repo.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/download/downloader.dart';
import 'package:boorusphere/presentation/provider/shared_storage_handle.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_updater.g.dart';

@riverpod
AppUpdater appUpdater(AppUpdaterRef ref) {
  return AppUpdater(ref);
}

@riverpod
DownloadProgress appUpdateProgress(AppUpdateProgressRef ref) {
  final id = ref.watch(appUpdaterProvider.select((it) => it.id));
  return ref.watch(downloadProgressStateProvider).getById(id);
}

class AppUpdater {
  AppUpdater(this.ref);

  final Ref ref;

  String id = '';
  AppVersion _version = AppVersion.zero;

  String _fileNameOf(AppVersion version) {
    return 'boorusphere-$version-$kAppArch.apk';
  }

  final updateDir = 'app-update';

  Future<void> clear() async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE file_name LIKE \'%.apk\'');
    if (tasks == null) return;
    for (var task in tasks) {
      await ref.read(downloadEntryStateProvider.notifier).remove(task.taskId);
      await FlutterDownloader.remove(
        taskId: task.taskId,
        shouldDeleteContent: true,
      );
    }
    id = '';
  }

  Future<void> start(AppVersion version) async {
    await clear();
    final fileName = _fileNameOf(version);
    final url = '${AppVersionRepo.gitUrl}/releases/download/$version/$fileName';

    final tmp = await getTemporaryDirectory();
    if (!tmp.existsSync()) {
      try {
        tmp.createSync();
        // ignore: empty_catches
      } catch (e) {}
    }

    final apk = File(path.join(tmp.absolute.path, fileName));
    if (apk.existsSync()) {
      try {
        apk.deleteSync();
        // ignore: empty_catches
      } catch (e) {}
    }

    final newId = await ref.read(downloaderProvider).download(
          Post.appReserved,
          url: url,
          targetPath: tmp.absolute.path,
          dest: (fileName) => path.join(updateDir, fileName),
        );

    if (newId != null) {
      _version = version;
      id = newId;
    }
  }

  Future<void> expose() async {
    final sharedStorageHandle = ref.read(sharedStorageHandleProvider);
    final file = _fileNameOf(_version);
    final tmp = await getTemporaryDirectory();

    await sharedStorageHandle.init();
    final destDir = sharedStorageHandle.createSubDir(updateDir);

    final srcApk = File(path.join(tmp.absolute.path, file));
    final destApk = File(path.join(destDir.absolute.path, file));

    if (srcApk.existsSync() && !destApk.existsSync()) {
      try {
        await srcApk.copy(destApk.absolute.path);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  Future<void> install() async {
    final file = _fileNameOf(_version);
    final tmp = await getTemporaryDirectory();
    await ref
        .read(sharedStorageHandleProvider)
        .open(file, on: tmp.absolute.path);
  }
}
