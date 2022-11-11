import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/data/repository/setting/setting_repo_impl.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final settingRepoProvider = Provider<SettingRepo>(
  (ref) => SettingRepoImpl(
    localSource: SettingLocalSource(Hive.box(SettingLocalSource.key)),
  ),
);
