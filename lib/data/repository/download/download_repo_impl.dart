import 'package:boorusphere/data/repository/download/datasource/downloader_source.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/domain/repository/download_repo.dart';

class DownloadRepoImpl implements DownloadRepo {
  DownloadRepoImpl(this.dataSource);

  final DownloaderSource dataSource;

  @override
  Iterable<DownloadEntry> getEntries() => dataSource.entries;

  @override
  Iterable<DownloadProgress> getProgresses() => dataSource.progresses;

  @override
  Future<void> add(DownloadEntry entry) => dataSource.add(entry);

  @override
  Future<void> remove(String id) => dataSource.remove(id);

  @override
  Future<void> clear() => dataSource.clear();

  @override
  Future<void> updateProgress(DownloadProgress progress) =>
      dataSource.updateProgress(progress);
}
