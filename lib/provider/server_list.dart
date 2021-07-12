import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';
import 'common.dart';

class ServerListState extends StateNotifier<List<ServerData>> {
  ServerListState(this.read) : super([]);

  final Reader read;

  Future<void> init() async {
    final serverBox = await read(serversBox);
    if (serverBox.isEmpty) {
      state = await defaultServers();
      updateServers(state);
    } else {
      state = serverBox.values.map((it) => it as ServerData).toList();
    }
  }

  Future<List<ServerData>> defaultServers() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final serverList = jsonDecode(json) as List;

    return serverList.map((it) => ServerData.fromJson(it)).toList();
  }

  ServerData select(String name) {
    return state.firstWhere((element) => element.name == name);
  }

  Future<void> updateServers(List<ServerData> servers) async {
    final serverBox = await read(serversBox);

    if (servers.isNotEmpty) {
      serverBox.clear();
    }
    serverBox.addAll(servers);
  }
}
