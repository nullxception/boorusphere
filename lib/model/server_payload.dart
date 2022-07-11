import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_payload.freezed.dart';

enum ServerPayloadType {
  search,
  suggestion,
  post,
}

@freezed
class ServerPayload with _$ServerPayload {
  const factory ServerPayload({
    @Default('') String host,
    @Default('') String query,
    @Default(ServerPayloadType.search) ServerPayloadType type,
  }) = _ServerPayload;
}
