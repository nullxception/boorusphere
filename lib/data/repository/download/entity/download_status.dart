import 'package:hive/hive.dart';

part 'download_status.g.dart';

@HiveType(typeId: 9, adapterName: 'DownloadStatusAdapter')
enum DownloadStatus {
  @HiveField(0)
  empty,
  @HiveField(1)
  pending,
  @HiveField(2)
  downloading,
  @HiveField(3)
  downloaded,
  @HiveField(4)
  failed,
  @HiveField(5)
  canceled,
  @HiveField(6)
  paused;

  bool get isPending => this == DownloadStatus.pending;
  bool get isDownloading => this == DownloadStatus.downloading;
  bool get isDownloaded => this == DownloadStatus.downloaded;
  bool get isFailed => this == DownloadStatus.failed;
  bool get isCanceled => this == DownloadStatus.canceled;
  bool get isPaused => this == DownloadStatus.paused;
  bool get isEmpty => this == DownloadStatus.empty;
}
