import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../source/changelog.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/notice_card.dart';

class ChangelogPage extends ConsumerWidget {
  const ChangelogPage({
    super.key,
    required this.option,
    this.title = 'Changelog',
  });

  final ChangelogOption option;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelog = ref.watch(changelogProvider(option));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: changelog.when(
        data: (data) => Markdown(
          data: data,
          selectable: true,
        ),
        error: (e, s) => Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Center(
              child: NoticeCard(
                icon: Icon(Icons.cancel_rounded),
                children: Text('No changelog available'),
              ),
            ),
          ],
        ),
        loading: () => Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SpinKitFoldingCube(
                size: 24,
                color: context.colorScheme.primary,
                duration: const Duration(seconds: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
