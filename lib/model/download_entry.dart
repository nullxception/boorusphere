import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'booru_post.dart';

part 'download_entry.freezed.dart';
part 'download_entry.g.dart';

@freezed
class DownloadEntry with _$DownloadEntry {
  @HiveType(typeId: 4, adapterName: 'DownloadEntryAdapter')
  const factory DownloadEntry({
    @HiveField(0) required String id,
    @HiveField(1) required BooruPost booru,
  }) = _DownloadEntry;

  static const none = DownloadEntry(id: '', booru: BooruPost.empty);
}
