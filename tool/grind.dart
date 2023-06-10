import 'dart:convert';
import 'dart:io';

import 'package:grinder/grinder.dart';

main(args) => grind(args);

final utf8Opt = RunOptions(stdoutEncoding: utf8, stderrEncoding: utf8);

Future<void> fun(List<String> args) =>
    runAsync('flutter', arguments: args, runOptions: utf8Opt);

@DefaultTask()
listTasks() {
  final buf = StringBuffer();
  for (var task in context.grinder.tasks) {
    if (context.grinder.defaultTask == task) {
      continue;
    }

    final deps = context.grinder.getImmediateDependencies(task);
    final ansi = context.grinder.ansi;
    final label = task.name;
    final diff = label.length - task.name.length;
    buf.write('${ansi.blue}${label.padRight(10 + diff)}${ansi.none}');

    if (task.description?.isNotEmpty ?? false) {
      buf.writeln(' ${task.description}');
    }

    final depTasks =
        deps.map((d) => '${ansi.blue}${d.name}${ansi.none}').join(', ');
    final depText = '  󱞩 ${ansi.red}depends on${ansi.none}: $depTasks';
    if (deps.isNotEmpty) {
      buf.writeln(depText);
    }
  }

  log(buf.toString());
}

@Task('Generate code')
Future<void> gencode() async {
  await Pub.runAsync(
    'build_runner',
    arguments: [
      'build',
      '--delete-conflicting-outputs',
    ],
    runOptions: utf8Opt,
  );
}

@Task('Generate localization')
Future<void> genlang() async {
  await Pub.runAsync('slang', runOptions: utf8Opt);
}

@Task('Generate pigeon bindings')
Future<void> pigeons() async {
  final files = Directory('pigeons')
      .listSync(recursive: true)
      .where((x) => x is File && x.path.endsWith('.pi.dart'))
      .fold(<String>[], (prev, x) => [...prev, '--input', x.path]);

  await Pub.runAsync('pigeon', arguments: files, runOptions: utf8Opt);
}

@Task('Check formatting')
Future<void> checkfmt() async {
  final files = Directory('lib')
      .listSync(recursive: true)
      .where((x) =>
          x is File &&
          x.path.endsWith('.dart') &&
          !x.path.contains(RegExp(r'\.(freezed|g|gr|pi)\.dart$')))
      .map((x) => x.path);

  await runAsync(
    'dart',
    arguments: [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...files,
    ],
    runOptions: utf8Opt,
  );
}

@Task('Analyze code')
@Depends(checkfmt)
Future<void> analyze() async {
  await fun(['analyze']);
}

@Task('Unit test')
Future<void> unittest() async {
  await Pub.runAsync('full_coverage', runOptions: utf8Opt);
  await fun(['test', '--coverage']);
}

@Task('Test all things')
@Depends(analyze, unittest)
void test() {}

@Task('Release')
@Depends(gencode, genlang)
Future<void> release() async {
  await fun(['build', 'apk', '--split-per-abi']);
  await Pub.runAsync('boorusphere', script: 'renameapks', runOptions: utf8Opt);
}
