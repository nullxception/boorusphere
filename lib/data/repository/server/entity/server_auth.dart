import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_auth.freezed.dart';
part 'server_auth.g.dart';

@freezed
class ServerAuth with _$ServerAuth {
  @HiveType(typeId: 11, adapterName: 'ServerAuthAdapter')
  const factory ServerAuth({
    @HiveField(0, defaultValue: '') @Default('') String serverId,
    @HiveField(1, defaultValue: '') @Default('') String builderId,
    @HiveField(2, defaultValue: '') @Default('') String userId,
    @HiveField(3, defaultValue: '') @Default('') String userKey,
  }) = _ServerAuth;

  factory ServerAuth.fromJson(Map<String, dynamic> json) =>
      _$ServerAuthFromJson(json);

  const ServerAuth._();

  static const ServerAuth empty = ServerAuth();
}
