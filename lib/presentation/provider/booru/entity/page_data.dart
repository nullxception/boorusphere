import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_data.freezed.dart';

@freezed
class PageData with _$PageData {
  const factory PageData({
    @Default(PageOption(clear: true)) PageOption option,
    @Default(<Post>[]) List<Post> posts,
  }) = _PageData;
}
