// ignore_for_file: constant_identifier_names

import 'package:hive/hive.dart';

enum Settings {
  blur_explicit_post,
  download_group_by_server,
  server_active,
  server_safe_mode,
  server_post_limit,
  theme_mode,
  timeline_grid_number,
  ui_theme_darker,
  videoplayer_mute;

  T read<T>({required T or}) => storage.get(name) ?? or;
  Future<void> save<T>(T value) async => await storage.put(name, value);
  static Box get storage => Hive.box('settings');
}
