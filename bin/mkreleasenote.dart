import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

typedef Changelog = MapEntry<String, List<String>>;

List<Changelog> parseChangelog(String string) {
  final data = <Changelog>[];

  final lines = const LineSplitter()
      .convert(string)
      .map((it) => it.trim())
      .where((it) => it.isNotEmpty);

  for (final line in lines) {
    if (line.startsWith('## ')) {
      final ver = line.replaceFirst('## ', '').trim();
      data.add(Changelog(ver, []));
    } else if (line.startsWith('* ')) {
      final log = line.replaceFirst('* ', '').trim();
      data.last = Changelog(data.last.key, [...data.last.value, log]);
    } else if (line.isNotEmpty && data.last.value.isNotEmpty) {
      final newlinelog = '${data.last.value.last}\n$line';
      final lastlog = data.last.value.sublist(0, data.last.value.length - 1);
      data.last = Changelog(data.last.key, [...lastlog, newlinelog]);
    }
  }
  return data;
}

void main() async {
  final text = StringBuffer();

  final notes = File(path.join(Directory.current.path, 'releasenote.md'));
  final changelog = File(path.join(Directory.current.path, 'CHANGELOG.md'));

  final data = parseChangelog(changelog.readAsStringSync());
  final Changelog(key: version, value: logs) = data.first;

  text.writeln("# What's new in $version");
  text.writeln();
  for (final log in logs) {
    text.writeln('- $log');
  }

  notes.writeAsStringSync(text.toString());
}
