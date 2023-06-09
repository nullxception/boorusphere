import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'download_entry.freezed.dart';
part 'download_entry.g.dart';

@freezed
class DownloadEntry with _$DownloadEntry {
  @HiveType(typeId: 4, adapterName: 'DownloadEntryAdapter')
  const factory DownloadEntry({
    @HiveField(0, defaultValue: '') @Default('') String id,
    @HiveField(1, defaultValue: Post.empty) @Default(Post.empty) Post post,
    @HiveField(2, defaultValue: '') @Default('') String dest,
  }) = _DownloadEntry;
  const DownloadEntry._();

  static const empty = DownloadEntry();
}
