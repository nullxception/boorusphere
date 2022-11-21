import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'downloads.freezed.dart';

@freezed
class Downloads with _$Downloads {
  const factory Downloads({
    @Default(IListConst([])) IList<DownloadEntry> entries,
    @Default(ISetConst({})) ISet<DownloadProgress> progresses,
  }) = _Downloads;
  const Downloads._();

  DownloadProgress getProgressById(String id) {
    return progresses.firstWhere(
      (it) => it.id == id,
      orElse: () => DownloadProgress.none,
    );
  }

  DownloadProgress getProgressByPost(Post post) {
    final entry = entries.lastWhere(
      (it) => it.post == post,
      orElse: () => DownloadEntry.empty,
    );
    return getProgressById(entry.id);
  }
}
