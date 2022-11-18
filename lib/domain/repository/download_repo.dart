import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';

abstract class DownloadRepo {
  Iterable<DownloadEntry> getEntries();
  Future<Iterable<DownloadProgress>> getProgress();
  Future<void> add(DownloadEntry entry);
  Future<void> remove(String id);
  Future<void> clear();
}
