import 'dart:convert';

import 'package:boorusphere/data/entity/app_version.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'changelog_data.freezed.dart';

@freezed
class ChangelogData with _$ChangelogData {
  const factory ChangelogData({
    @Default(AppVersion.zero) AppVersion version,
    @Default([]) List<String> logs,
  }) = _ChangelogData;
  const ChangelogData._();

  static List<ChangelogData> fromString(String string) {
    final data = <ChangelogData>[];

    final lines = const LineSplitter()
        .convert(string)
        .map((it) => it.trim())
        .where((it) => it.isNotEmpty);

    for (final line in lines) {
      if (line.startsWith('## ')) {
        final text = line.replaceFirst('## ', '').trim();
        data.add(ChangelogData(version: AppVersion.fromString(text)));
      } else if (line.startsWith('* ')) {
        final text = line.replaceFirst('* ', '').trim();
        data.last = data.last.copyWith(logs: [...data.last.logs, text]);
      } else if (line.isNotEmpty && data.last.logs.isNotEmpty) {
        final text = line;
        data.last = data.last.copyWith(logs: [
          ...data.last.logs.sublist(0, data.last.logs.length - 1),
          '${data.last.logs.last}\n$text',
        ]);
      }
    }
    return data;
  }

  static const empty = ChangelogData();
}
