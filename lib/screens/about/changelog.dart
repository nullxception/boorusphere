import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../widgets/notice_card.dart';

class ChangelogPage extends HookWidget {
  const ChangelogPage({
    super.key,
    required this.dataSource,
    this.title = 'Changelog',
  });
  final Future<String> dataSource;
  final String title;

  @override
  Widget build(BuildContext context) {
    final changelog = useFuture(dataSource);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: changelog.data != null
          ? Markdown(
              data: changelog.data!,
              selectable: true,
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(
                  child: NoticeCard(
                      icon: Icon(Icons.cancel_rounded),
                      children: Text('No changelog available')),
                ),
              ],
            ),
    );
  }
}
