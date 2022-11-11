import 'package:hive/hive.dart';

class SettingLocalSource {
  SettingLocalSource(this.box);

  final Box box;

  T get<T>(String name, {required T or}) => box.get(name) ?? or;

  Future<void> put<T>(String name, T value) => box.put(name, value);

  static String key = 'settings';
}
