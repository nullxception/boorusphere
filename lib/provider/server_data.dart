import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'booru_api.dart';
import 'hive_boxes.dart';

class ServerDataNotifier extends ChangeNotifier {
  final Reader read;
  late List<ServerData> _serverList;
  late ServerData _activeServer;

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
    }
    _serverList = server.values.map((it) => it as ServerData).toList();

    final activeServerName = prefs.get('active_server');
    _activeServer = select(activeServerName ?? ServerData.defaultServerName);

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
    return _serverList.firstWhere((element) => element.name == name,
        orElse: () => _serverList.first);
  }

  Future<void> setActiveServer({required String name}) async {
    if (name != _activeServer.name) {
      _activeServer = select(name);
      final prefs = await read(settingsBox);
      prefs.put('active_server', name);
    }
  }

  void addServer({required ServerData data}) async {
    final server = await read(serverBox);
    server.put(data.homepage, data);
    _serverList = server.values.map((it) => it as ServerData).toList();
    notifyListeners();
  }

  void removeServer({required ServerData data}) async {
    if (data.name == ServerData.defaultServerName) {
      throw Exception('Default server cannot be deleted');
    }
    final server = await read(serverBox);
    server.delete(data.homepage);
    _serverList = server.values.map((it) => it as ServerData).toList();
    if (_activeServer == data) {
      setActiveServer(name: _serverList.first.name);
    }
    notifyListeners();
  }
}

final serverDataProvider =
    ChangeNotifierProvider((ref) => ServerDataNotifier(ref.read));
