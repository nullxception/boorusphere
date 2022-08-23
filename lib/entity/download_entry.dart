import 'dart:io';

import 'package:hive/hive.dart';

import '../utils/extensions/string.dart';
import 'post.dart';

part 'download_entry.g.dart';

@HiveType(typeId: 4, adapterName: 'DownloadEntryAdapter')
class DownloadEntry {
  const DownloadEntry({
    this.id = '',
    this.post = Post.empty,
    this.destination = '',
  });

  @HiveField(0, defaultValue: '')
  final String id;
  @HiveField(1, defaultValue: Post.empty)
  final Post post;
  @HiveField(2, defaultValue: '')
  final String destination;

  bool get isFileExists => File(destination.asDecoded).existsSync();

  DownloadEntry copyWith({
    String? id,
    Post? post,
    String? destination,
  }) {
    return DownloadEntry(
      id: id ?? this.id,
      post: post ?? this.post,
      destination: destination ?? this.destination,
    );
  }

  @override
  bool operator ==(covariant DownloadEntry other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.post == post &&
        other.destination == destination;
  }

  @override
  int get hashCode => id.hashCode ^ post.hashCode ^ destination.hashCode;

  static const empty = DownloadEntry();
}
