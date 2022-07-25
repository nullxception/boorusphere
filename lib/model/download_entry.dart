import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'post.dart';

part 'download_entry.freezed.dart';
part 'download_entry.g.dart';

@freezed
class DownloadEntry with _$DownloadEntry {
  @HiveType(typeId: 4, adapterName: 'DownloadEntryAdapter')
  const factory DownloadEntry({
    @HiveField(0, defaultValue: '') required String id,
    @HiveField(1, defaultValue: Post.empty) required Post post,
    @HiveField(2, defaultValue: '') required String destination,
  }) = _DownloadEntry;

  static const empty = DownloadEntry(id: '', post: Post.empty, destination: '');
}
