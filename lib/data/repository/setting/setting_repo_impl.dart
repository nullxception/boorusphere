import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';

class SettingRepoImpl implements SettingRepo {
  SettingRepoImpl({required this.localSource});
  final SettingLocalSource localSource;

  @override
  T get<T>(Setting key, {required T or}) => localSource.get(key.name, or: or);

  @override
  Future<void> put<T>(Setting key, T value) => localSource.put(key.name, value);
}
