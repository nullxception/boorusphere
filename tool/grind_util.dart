import 'package:collection/collection.dart';
import 'package:grinder/grinder.dart';

Future<void> tasks() async {
  final buf = StringBuffer();
  final sortedTasks = context.grinder.tasks;
  sortedTasks.sortBy((x) => x.name);
  for (var task in sortedTasks) {
    if (context.grinder.defaultTask == task) {
      continue;
    }

    final taskDeps = context.grinder.getImmediateDependencies(task);
    final ansi = context.grinder.ansi;
    final diff = task.name.length - task.name.length;
    buf.write('${ansi.blue}${task.name.padRight(20 + diff)}${ansi.none}');

    if (task.description?.isNotEmpty ?? false) {
      buf.writeln(' ${task.description}');
    }

    final deps =
        taskDeps.map((d) => '${ansi.blue}${d.name}${ansi.none}').join('  ');
    if (taskDeps.isNotEmpty) {
      buf.writeln('  󱞩 ${ansi.red}execute: ${ansi.none}$deps');
    }
  }

  log(buf.toString());
}
