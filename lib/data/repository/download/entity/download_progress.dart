import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'download_progress.freezed.dart';
part 'download_progress.g.dart';

@freezed
class DownloadProgress with _$DownloadProgress {
  @HiveType(typeId: 10, adapterName: 'DownloadProgressAdapter')
  const factory DownloadProgress({
    @HiveField(0, defaultValue: '') @Default('') String id,
    @HiveField(1, defaultValue: DownloadStatus.empty)
    @Default(DownloadStatus.empty)
    DownloadStatus status,
    @HiveField(2, defaultValue: 0) @Default(0) int progress,
    @HiveField(3, defaultValue: 0) @Default(0) int timestamp,
  }) = _DownloadProgress;
  const DownloadProgress._();

  static const none = DownloadProgress();
}
