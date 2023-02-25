import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_setting.freezed.dart';

@freezed
class DownloadSetting with _$DownloadSetting {
  const factory DownloadSetting({
    @Default(false) bool groupByServer,
    @Default(DownloadQuality.ask) DownloadQuality quality,
  }) = _DownloadSetting;
}
