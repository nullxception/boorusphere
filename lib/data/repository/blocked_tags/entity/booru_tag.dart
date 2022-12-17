import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'booru_tag.freezed.dart';
part 'booru_tag.g.dart';

@freezed
class BooruTag with _$BooruTag {
  @HiveType(typeId: 6, adapterName: 'BooruTagAdapter')
  const factory BooruTag({
    @HiveField(0, defaultValue: '') @Default('') String serverId,
    @HiveField(1, defaultValue: '') @Default('') String name,
  }) = _BooruTag;

  factory BooruTag.fromJson(Map<String, dynamic> json) =>
      _$BooruTagFromJson(json);
}
