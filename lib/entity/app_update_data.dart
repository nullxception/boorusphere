import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_version.dart';

part 'app_update_data.freezed.dart';

@freezed
class AppUpdateData with _$AppUpdateData {
  const AppUpdateData._();

  const factory AppUpdateData({
    @Default('armeabi-v7a') String arch,
    @Default(AppVersion.zero) AppVersion currentVersion,
    @Default(AppVersion.zero) AppVersion newVersion,
    @Default('') String apkUrl,
  }) = _AppUpdateData;

  get shouldUpdate => newVersion.isNewerThan(currentVersion);

  static const empty = AppUpdateData();
}
