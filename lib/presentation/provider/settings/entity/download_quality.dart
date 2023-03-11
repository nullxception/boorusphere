import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'download_quality.g.dart';

@HiveType(typeId: 8, adapterName: 'DownloadQualityAdapter')
enum DownloadQuality {
  @HiveField(0)
  ask,
  @HiveField(1)
  original,
  @HiveField(2)
  sample;

  String describe(BuildContext context) {
    switch (this) {
      case original:
        return context.t.fileOg;
      case sample:
        return context.t.fileSample;
      default:
        return context.t.alwaysAsk;
    }
  }

  static DownloadQuality fromName(String name) {
    return DownloadQuality.values
        .firstWhere((it) => it.name == name, orElse: () => DownloadQuality.ask);
  }
}
