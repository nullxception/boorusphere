import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../model/booru_post.dart';
import 'api_provider.dart';
import 'blocked_tags.dart';
import 'grid.dart';
import 'safe_mode.dart';
import 'search_history.dart';
import 'search_tag.dart';
import 'server.dart';
import 'style_provider.dart';
import 'ui_theme.dart';
import 'version.dart';
import 'video_player.dart';

// Hive Boxes
final searchHistoryBox = Provider((_) => Hive.openBox('searchHistory'));
final settingsBox = Provider((_) => Hive.openBox('settings'));
final serversBox = Provider((_) => Hive.openBox('servers'));
final blockedTagsBox = Provider((_) => Hive.openBox('blockedTags'));

// Common Providers
final blockedTagsProvider = Provider((ref) => BlockedTagsRepository(ref.read));
final pageLoadingProvider = StateProvider((_) => false);
final homeDrawerSwipeableProvider = StateProvider((_) => true);
final errorMessageProvider = StateProvider((_) => '');
final lastOpenedPostProvider = StateProvider((_) => -1);
final booruPostsProvider = Provider<List<BooruPost>>((_) => []);
final apiProvider = Provider((ref) => ApiProvider(ref.read));
final styleProvider = ChangeNotifierProvider((_) => StyleProvider());

final searchHistoryProvider = Provider((ref) {
  return SearchHistoryRepository(ref.read);
});

final serverProvider = ChangeNotifierProvider((ref) {
  return ServerState(ref.read)..init();
});

final uiThemeProvider = StateNotifierProvider<UIThemeState, ThemeMode>((ref) {
  return UIThemeState(ref.read)..init();
});

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  return SafeModeState(ref.read)..init();
});

final searchTagProvider = StateNotifierProvider<SearchTagState, String>((ref) {
  return SearchTagState(ref.read);
});

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  return GridState(ref.read);
});

final videoPlayerProvider = ChangeNotifierProvider<VideoPlayerState>((ref) {
  return VideoPlayerState(ref.read);
});

final versionProvider = ChangeNotifierProvider<VersionState>((ref) {
  return VersionState(ref.read);
});
