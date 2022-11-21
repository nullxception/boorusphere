import 'dart:io';

import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_data.freezed.dart';

@freezed
class PageData with _$PageData {
  const factory PageData({
    @Default(PageOption(clear: true)) PageOption option,
    @Default(IListConst([])) IList<Post> posts,
    @Default(IListConst([])) IList<Cookie> cookies,
  }) = _PageData;
}
