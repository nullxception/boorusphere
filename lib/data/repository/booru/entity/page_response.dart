import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:flutter/foundation.dart';

class PageResponse {
  PageResponse({
    required this.src,
    required this.data,
  });

  final String src;
  final List<Post> data;

  PageResponse copyWith({
    String? url,
    List<Post>? data,
  }) {
    return PageResponse(
      src: url ?? src,
      data: data ?? this.data,
    );
  }

  @override
  String toString() => 'PageResponse(url: $src, data: $data)';

  @override
  bool operator ==(covariant PageResponse other) {
    if (identical(this, other)) return true;

    return other.src == src && listEquals(other.data, data);
  }

  @override
  int get hashCode => src.hashCode ^ data.hashCode;
}
