import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_setting.freezed.dart';

@freezed
class ContentSetting with _$ContentSetting {
  const factory ContentSetting({
    @Default(true) bool blurExplicit,
    @Default(false) bool loadOriginal,
    @Default(false) bool videoMuted,
  }) = _ContentSetting;
}
