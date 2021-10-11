import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'booru_api.dart';
import 'hive_boxes.dart';

class ServerDataNotifier extends ChangeNotifier {
  final Reader read;
  List<ServerData> _serverList = [];
  ServerData _activeServer = defaultServer;

  ServerDataNotifier(this.read) {
    _init();
  }

  List<ServerData> get all => _serverList;
  ServerData get active => _activeServer;

  Future<void> _init() async {
    final api = read(booruApiProvider);
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
      _activeServer = select(activeServerName);
    }

    api.posts.clear();
    api.fetch();
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
      _activeServer = read(serverDataProvider).select(name);
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

final serverDataProvider =
    ChangeNotifierProvider((ref) => ServerDataNotifier(ref.read));
