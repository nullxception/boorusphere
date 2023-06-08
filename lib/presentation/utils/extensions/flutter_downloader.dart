import 'package:boorusphere/data/repository/downloads/entity/download_status.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

extension DownloadTaskStatusExt on DownloadTaskStatus {
  DownloadStatus toDownloadStatus() {
    switch (this) {
      case DownloadTaskStatus.enqueued:
        return DownloadStatus.pending;
      case DownloadTaskStatus.running:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.complete:
        return DownloadStatus.downloaded;
      case DownloadTaskStatus.failed:
        return DownloadStatus.failed;
      case DownloadTaskStatus.canceled:
        return DownloadStatus.canceled;
      case DownloadTaskStatus.paused:
        return DownloadStatus.paused;
      default:
        return DownloadStatus.empty;
    }
  }
}
