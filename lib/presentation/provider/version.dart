import 'package:boorusphere/domain/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final versionCurrentProvider = FutureProvider((ref) {
  final repo = ref.read(versionRepoProvider);
  return repo.get();
});

final versionLatestProvider = FutureProvider((ref) {
  final repo = ref.read(versionRepoProvider);
  return repo.fetch();
});
