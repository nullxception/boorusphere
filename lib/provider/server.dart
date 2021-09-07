import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'common.dart';

class ServerState extends ChangeNotifier {
  final Reader read;
  List<ServerData> _serverList = [];
  ServerData _activeServer = defaultServer;

  ServerState(this.read);

  List<ServerData> get all => _serverList;
  ServerData get active => _activeServer;

  Future<void> init() async {
    final api = read(apiProvider);
    final prefs = await read(settingsBox);
    final serverBox = await read(serversBox);

    if (serverBox.isEmpty) {
      final fromAssets = await _defaultServersAssets();
      serverBox.addAll(fromAssets);
      _serverList = fromAssets;
    } else {
      _serverList = serverBox.values.map((it) => it as ServerData).toList();
    }

    final activeServerName = prefs.get('active_server');
    if (activeServerName != null && _activeServer.name != activeServerName) {
      _activeServer = read(serverProvider).select(activeServerName);
    }

    api.fetch(clear: true);
  }

  Future<List<ServerData>> _defaultServersAssets() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final servers = jsonDecode(json) as List;

    return servers.map((it) => ServerData.fromJson(it)).toList();
  }

  ServerData select(String name) {
    return _serverList.firstWhere((element) => element.name == name);
  }

  Future<void> setActiveServer({required String name}) async {
    if (name != _activeServer.name) {
      _activeServer = read(serverProvider).select(name);
      final prefs = await read(settingsBox);
      prefs.put('active_server', name);
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
