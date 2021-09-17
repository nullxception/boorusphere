import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_query.freezed.dart';

@freezed
class ServerQuery with _$ServerQuery {
  const factory ServerQuery({
    @Default('*') String tags,
    @Default(true) bool safeMode,
  }) = _ServerQuery;
}
