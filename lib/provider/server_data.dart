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
    final server = await read(serverBox);

    if (server.isEmpty) {
      final fromAssets = await _defaultServersAssets();
      server.putAll(fromAssets);
      _serverList = fromAssets.values.toList();
    } else {
      _serverList = server.values.map((it) => it as ServerData).toList();
    }

    final activeServerName = prefs.get('active_server');
    if (activeServerName != null && _activeServer.name != activeServerName) {
      _activeServer = select(activeServerName);
    }

    api.posts.clear();
    api.fetch();
  }

  Future<Map<String, ServerData>> _defaultServersAssets() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final servers = jsonDecode(json) as List;

    return Map.fromEntries(servers.map((it) {
      final value = ServerData.fromJson(it);
      return MapEntry(value.homepage, value);
    }));
  }

  ServerData select(String name) {
    return _serverList.firstWhere((element) => element.name == name);
  }

  Future<void> setActiveServer({required String name}) async {
    if (name != _activeServer.name) {
      _activeServer = select(name);
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
