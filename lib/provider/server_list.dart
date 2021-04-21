import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_data.dart';

class ServerListState extends StateNotifier<List<ServerData>> {
  ServerListState(this.read) : super([]);

  final Reader read;

  Future<void> loadFromAssets() async {
    final json = await rootBundle.loadString('assets/servers.json');
    final serverList = jsonDecode(json) as List;

    state = serverList.map((it) => ServerData.fromJson(it)).toList();
  }

  ServerData select(String name) {
    return state.firstWhere((element) => element.name == name);
  }
}
