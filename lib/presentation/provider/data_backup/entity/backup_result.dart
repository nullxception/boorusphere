import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_result.freezed.dart';

@freezed
class BackupResult with _$BackupResult {
  const factory BackupResult.idle() = IdleBackupResult;
  const factory BackupResult.imported() = ImportedBackupResult;
  const factory BackupResult.exported(String path) = ExportedBackupResult;
  const factory BackupResult.loading() = LoadingBackupResult;
  const factory BackupResult.error({Object? error, StackTrace? stackTrace}) =
      ErrorBackupResult;
}
