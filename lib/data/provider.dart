import 'dart:convert';

import 'package:boorusphere/data/dio/app_dio.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
CookieJar cookieJar(CookieJarRef ref) {
  return CookieJar();
}

Future<CookieJar> provideCookieJar() async {
  final dir = await getApplicationDocumentsDirectory();
  return PersistCookieJar(
    storage: FileStorage(path.join(dir.path, 'cookies')),
  );
}

@Riverpod(keepAlive: true)
Map<String, Server> defaultServers(DefaultServersRef ref) {
  return {};
}

Future<Map<String, Server>> provideDefaultServers() async {
  final json = await rootBundle.loadString('assets/servers.json');
  final servers = jsonDecode(json) as List;
  return Map.fromEntries(servers.map((it) {
    final value = Server.fromJson(it);
    return MapEntry(value.key, value);
  }));
}

@riverpod
Dio dio(DioRef ref) {
  final cookieJar = ref.watch(cookieJarProvider);
  final envRepo = ref.watch(envRepoProvider);
  return AppDio(cookieJar: cookieJar, envRepo: envRepo);
}
