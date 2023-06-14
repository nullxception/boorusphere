import 'package:freezed_annotation/freezed_annotation.dart';

part 'booru_auth.freezed.dart';

enum BooruAuthType { none, headers }

@freezed
class BooruAuth with _$BooruAuth {
  const factory BooruAuth({
    @Default(BooruAuthType.none) BooruAuthType type,
    data,
  }) = _BooruAuth;
  const BooruAuth._();

  static const none = BooruAuth();
}
