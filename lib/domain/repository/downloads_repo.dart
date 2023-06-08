import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';

abstract interface class DownloadsRepo {
  Iterable<DownloadEntry> getEntries();
  Iterable<DownloadProgress> getProgresses();
  Future<void> updateProgress(DownloadProgress progress);
  Future<void> add(DownloadEntry entry);
  Future<void> remove(String id);
  Future<void> clear();
}
