import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider/blocked_tags.dart';
import 'package:boorusphere/domain/provider/booru.dart';
import 'package:boorusphere/presentation/provider/settings/server/server_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestionFuture = FutureProvider.autoDispose
    .family<Iterable<String>, String>((ref, query) async {
  final server = ref.watch(ServerSettingsProvider.active);
  if (server == ServerData.empty) {
    return {};
  }
  final repo = ref.watch(booruRepoProvider);
  final blockedTags = ref.watch(blockedTagsRepoProvider);
  final result = await repo.getSuggestion(query);
  return result.where((it) => !blockedTags.get().values.contains(it));
});
