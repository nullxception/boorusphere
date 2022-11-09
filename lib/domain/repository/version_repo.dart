import 'package:boorusphere/data/repository/version/entity/app_version.dart';

abstract class VersionRepo {
  Future<AppVersion> get();
  Future<AppVersion> fetch();
}
