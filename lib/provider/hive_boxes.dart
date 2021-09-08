import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final searchHistoryBox = Provider((_) => Hive.openBox('searchHistory'));
final settingsBox = Provider((_) => Hive.openBox('settings'));
final serversBox = Provider((_) => Hive.openBox('servers'));
final blockedTagsBox = Provider((_) => Hive.openBox('blockedTags'));
