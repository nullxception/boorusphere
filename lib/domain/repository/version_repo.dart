import 'package:boorusphere/data/repository/version/entity/app_version.dart';

abstract interface class VersionRepo {
  AppVersion get current;
  Future<AppVersion> fetch();
}
