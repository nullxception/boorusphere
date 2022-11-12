import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider/blocked_tags.dart';
import 'package:boorusphere/domain/provider/booru.dart';
import 'package:boorusphere/presentation/provider/setting/server/active.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestionFuture = FutureProvider.autoDispose
    .family<Iterable<String>, String>((ref, query) async {
  final serverActive = ref.watch(serverActiveProvider);
  if (serverActive == ServerData.empty) {
    return {};
  }
  final repo = ref.watch(booruRepoProvider);
  final blockedTags = ref.watch(blockedTagsRepoProvider);
  final result = await repo.getSuggestion(query);
  return result.where((it) => !blockedTags.get().values.contains(it));
});
