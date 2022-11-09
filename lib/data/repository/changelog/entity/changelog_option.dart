import 'package:boorusphere/data/entity/app_version.dart';
import 'package:boorusphere/data/repository/changelog/entity/changelog_type.dart';

class ChangelogOption {
  const ChangelogOption({
    required this.type,
    this.version,
  });

  final ChangelogType type;
  final AppVersion? version;
}
