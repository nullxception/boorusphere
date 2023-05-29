import 'package:boorusphere/data/repository/setting/entity/setting.dart';

abstract interface class SettingRepo {
  T get<T>(Setting key, {required T or});

  Future<void> put<T>(Setting key, T value);
}
