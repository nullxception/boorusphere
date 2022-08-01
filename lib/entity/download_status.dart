enum DownloadStatus {
  empty,
  pending,
  downloading,
  downloaded,
  failed,
  canceled,
  paused;

  bool get isPending => this == DownloadStatus.pending;
  bool get isDownloading => this == DownloadStatus.downloading;
  bool get isDownloaded => this == DownloadStatus.downloaded;
  bool get isFailed => this == DownloadStatus.failed;
  bool get isCanceled => this == DownloadStatus.canceled;
  bool get isPaused => this == DownloadStatus.paused;

  static DownloadStatus fromIndex(int index) {
    return DownloadStatus.values.firstWhere((it) => it.index == index,
        orElse: () => DownloadStatus.empty);
  }
}
