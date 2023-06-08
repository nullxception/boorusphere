import 'package:boorusphere/data/repository/downloads/entity/download_status.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:flutter/material.dart';

enum DownloadFilter {
  none,
  downloading,
  failed,
  downloaded;

  DownloadStatus? toStatus() {
    switch (this) {
      case failed:
        return DownloadStatus.failed;
      case downloading:
        return DownloadStatus.downloading;
      case downloaded:
        return DownloadStatus.downloaded;
      default:
        return null;
    }
  }

  String describe(BuildContext context) {
    switch (this) {
      case failed:
        return context.t.downloads.status.failed;
      case downloading:
        return context.t.downloads.status.downloading;
      case downloaded:
        return context.t.downloads.status.downloaded;
      default:
        return context.t.downloads.noFilter;
    }
  }
}
