import 'package:boorusphere/data/entity/download_status.dart';

class DownloadProgress {
  const DownloadProgress({
    required this.id,
    required this.status,
    required this.progress,
    required this.timestamp,
  });

  final String id;
  final DownloadStatus status;
  final int progress;
  final int timestamp;

  static const DownloadProgress none = DownloadProgress(
    id: '',
    status: DownloadStatus.empty,
    progress: 0,
    timestamp: 0,
  );
}
