import 'package:boorusphere/domain/provider/version.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final versionCurrentProvider = FutureProvider((ref) {
  final repo = ref.watch(versionRepoProvider);
  return repo.get();
});

final versionLatestProvider = FutureProvider((ref) {
  final repo = ref.watch(versionRepoProvider);
  return repo.fetch();
});
