import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'common.dart';

class ActiveServerState extends StateNotifier<ServerData> {
  ActiveServerState(this.read) : super(defaultServer);

  final Reader read;

  Future<void> restoreFromPreference() async {
    final prefs = await read(preferenceProvider);
    final activeServerName = prefs.getString('active_server');
    if (activeServerName != null && state.name != activeServerName) {
      state = read(serverListProvider.notifier).select(activeServerName);
    }
  }

  Future<void> setActiveServer({required String name}) async {
    if (name != state.name) {
      state = read(serverListProvider.notifier).select(name);
      final prefs = await read(preferenceProvider);
      prefs.setString('active_server', name);
    }
  }

  static const defaultServer = ServerData(
    name: 'Safebooru',
    homepage: 'https://safebooru.org',
    postUrl: 'index.php?page=post&s=view&id={post-id}',
    searchUrl:
        'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}',
  );
}
