import 'dart:convert';
import 'dart:io';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:path/path.dart' as path;

File getFakeData(String file) {
  final fakeDataDir = path.join(Directory.current.path, 'test', 'fake_data');
  return File(path.join(fakeDataDir, file));
}

Iterable<Post> getSamplePosts() {
  final fakePostsFile = getFakeData('posts.json');
  final rawPosts = jsonDecode(fakePostsFile.readAsStringSync()) as Iterable;
  return rawPosts.map((it) => Post.fromJson(Map.from(it)));
}

Iterable<Server> getDefaultServerData() {
  final fromAssets =
      File(path.join(Directory.current.path, 'assets', 'servers.json'));
  final servers = jsonDecode(fromAssets.readAsStringSync()) as Iterable;
  return servers.map((it) => Server.fromJson(Map.from(it)));
}
