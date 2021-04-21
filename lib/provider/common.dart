import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/booru_post.dart';
import '../model/server_data.dart';
import 'active_server.dart';
import 'api_provider.dart';
import 'grid.dart';
import 'safe_mode.dart';
import 'search_tag.dart';
import 'server_list.dart';
import 'style_provider.dart';
import 'ui_theme.dart';

final preferenceProvider = Provider((_) => SharedPreferences.getInstance());
final pageLoadingProvider = StateProvider((_) => false);
final errorMessageProvider = StateProvider((_) => '');
final pageCacheProvider = StateProvider<List<BooruPost>>((_) => []);
final pagerProvider = StateProvider((_) => 1);
final apiProvider = Provider((ref) => ApiProvider(ref.read));
final styleProvider = ChangeNotifierProvider((_) => StyleProvider());

final uiThemeProvider = StateNotifierProvider<UIThemeState, ThemeMode>((_) {
  return UIThemeState();
});

final safeModeProvider = StateNotifierProvider<SafeModeState, bool>((ref) {
  return SafeModeState(ref.read);
});

final serverListProvider =
    StateNotifierProvider<ServerListState, List<ServerData>>((ref) {
  return ServerListState(ref.read);
});

final activeServerProvider =
    StateNotifierProvider<ActiveServerState, ServerData>((ref) {
  return ActiveServerState(ref.read);
});

final searchTagProvider = StateNotifierProvider<SearchTagState, String>((ref) {
  return SearchTagState(ref.read);
});

final gridProvider = StateNotifierProvider<GridState, int>((ref) {
  return GridState(ref.read);
});
