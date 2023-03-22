import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_session.freezed.dart';
part 'search_session.g.dart';

@freezed
class SearchSession with _$SearchSession {
  const factory SearchSession({
    @Default('') String query,
    @Default('') String serverId,
  }) = _SearchSession;
  const SearchSession._();
}

@riverpod
SearchSession searchSession(SearchSessionRef ref) {
  return const SearchSession();
}
