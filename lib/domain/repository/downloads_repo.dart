import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';

abstract interface class DownloadsRepo {
  Iterable<DownloadEntry> getEntries();
  Iterable<DownloadProgress> getProgresses();
  Future<void> addEntry(DownloadEntry entry);
  Future<void> updateProgress(DownloadProgress progress);
  Future<void> removeEntry(String id);
  Future<void> removeProgress(String id);
  Future<void> clearEntries();
  Future<void> clearProgresses();
}
