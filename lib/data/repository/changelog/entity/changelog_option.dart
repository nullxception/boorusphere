import 'package:boorusphere/data/repository/changelog/entity/changelog_type.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';

class ChangelogOption {
  const ChangelogOption({
    required this.type,
    this.version,
  });

  final ChangelogType type;
  final AppVersion? version;
}
