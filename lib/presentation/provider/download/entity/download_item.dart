import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_item.freezed.dart';

@freezed
class DownloadItem with _$DownloadItem {
  const factory DownloadItem({
    @Default(DownloadEntry.empty) DownloadEntry entry,
    @Default(DownloadProgress.none) DownloadProgress progress,
  }) = _DownloadItem;
  const DownloadItem._();
}
