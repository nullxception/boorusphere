import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_option.freezed.dart';

@freezed
class BackupOption with _$BackupOption {
  const factory BackupOption({
    @Default(true) bool searchHistory,
    @Default(true) bool server,
    @Default(true) bool blockedTags,
    @Default(true) bool favoritePost,
    @Default(true) bool setting,
  }) = _BackupOption;
}

extension BackupOptionX on BackupOption {
  bool isValid() =>
      (searchHistory || server || blockedTags || favoritePost || setting);
}
