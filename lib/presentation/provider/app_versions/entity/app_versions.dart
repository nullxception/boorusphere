import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_versions.freezed.dart';

@freezed
class AppVersions with _$AppVersions {
  const factory AppVersions({
    @Default(AppVersion.zero) AppVersion current,
    @Default(AppVersion.zero) AppVersion latest,
  }) = _AppVersions;
}
