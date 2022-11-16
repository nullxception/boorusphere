import 'package:boorusphere/data/repository/changelog/entity/changelog_data.dart';
import 'package:boorusphere/data/repository/changelog/entity/changelog_option.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/changelog.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          option.version == null
              ? t.changelog.title
              : changelog.maybeWhen(
                  data: (value) => t.version(version: '${option.version}'),
                  orElse: () => t.changelog.title,
                ),
        ),
      ),
      body: SafeArea(
        child: changelog.when(
          data: (data) => data.length == 1
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: ChangelogDataView(
                    changelog: data.first,
                    showVersion: false,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ChangelogDataView(changelog: data[index]);
                  },
                ),
          error: (e, s) => Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: NoticeCard(
                  icon: const Icon(Icons.cancel_rounded),
                  children: Text(t.changelog.none),
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
