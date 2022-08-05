import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../entity/changelog_data.dart';
import '../../source/changelog.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../widgets/notice_card.dart';

class ChangelogPage extends ConsumerWidget {
  const ChangelogPage({
    super.key,
    required this.option,
  });

  final ChangelogOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelog = ref.watch(changelogProvider(option));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          !option.latestOnly
              ? 'Changelog'
              : changelog.maybeWhen(
                  data: (value) => 'Version ${value.first.version}',
                  orElse: () => 'Changelog',
                ),
        ),
      ),
      body: SafeArea(
        child: changelog.when(
          data: (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (option.latestOnly)
                  ChangelogDataView(
                    changelog: data.first,
                    showVersion: false,
                  )
                else
                  ...data
                      .map((changelog) =>
                          ChangelogDataView(changelog: changelog))
                      .toList(),
              ],
            ),
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
      ),
    );
  }
}

class ChangelogDataView extends StatelessWidget {
  const ChangelogDataView(
      {super.key, required this.changelog, this.showVersion = true});

  final ChangelogData changelog;
  final bool showVersion;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showVersion)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${changelog.version}',
                style: const TextStyle(
                    fontSize: 22, height: 1.3, fontWeight: FontWeight.w300),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: changelog.logs
                  .map(
                    (it) => Text(
                      '\u2022  $it',
                      style: const TextStyle(height: 1.3),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
