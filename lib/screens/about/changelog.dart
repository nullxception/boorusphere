import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../utils/changelog.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/notice_card.dart';

final _changelogProvider =
    FutureProvider.family<String, ChangelogPageOption>((ref, arg) async {
  final data = await ChangelogUtils.from(arg.type);
  return arg.latestOnly ? ChangelogUtils.getLatest(data) : data;
});

class ChangelogPageOption {
  const ChangelogPageOption({
    required this.type,
    this.latestOnly = false,
  });
  final ChangelogType type;
  final bool latestOnly;
}

class ChangelogPage extends ConsumerWidget {
  const ChangelogPage({
    super.key,
    required this.option,
    this.title = 'Changelog',
  });

  final ChangelogPageOption option;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelog = ref.watch(_changelogProvider(option));
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
