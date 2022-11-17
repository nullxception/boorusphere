import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache.g.dart';

@Riverpod(keepAlive: true)
DefaultCacheManager cacheManager(CacheManagerRef ref) {
  return DefaultCacheManager();
}
