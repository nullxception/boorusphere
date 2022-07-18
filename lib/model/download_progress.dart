import 'package:freezed_annotation/freezed_annotation.dart';

import 'download_status.dart';

part 'download_progress.freezed.dart';

@freezed
class DownloadProgress with _$DownloadProgress {
  const factory DownloadProgress({
    required String id,
    required DownloadStatus status,
    required int progress,
  }) = _DownloadProgress;

  static const DownloadProgress none =
      DownloadProgress(id: '', status: DownloadStatus.empty, progress: 0);
}
