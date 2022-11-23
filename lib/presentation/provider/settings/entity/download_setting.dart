import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_setting.freezed.dart';

@freezed
class DownloadSetting with _$DownloadSetting {
  const factory DownloadSetting({
    @Default(false) bool groupByServer,
  }) = _DownloadSetting;
}
