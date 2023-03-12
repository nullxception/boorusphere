import 'package:boorusphere/data/repository/changelog/entity/changelog_data.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/changelog_state.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangelogPage extends ConsumerWidget {
  const ChangelogPage({
    super.key,
    required this.type,
    this.version,
  });

  final ChangelogType type;
  final AppVersion? version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelog = ref.watch(changelogStateProvider(type, version));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          version == null
              ? context.t.changelog.title
              : changelog.maybeWhen(
                  data: (value) => context.t.version(version: '$version'),
                  orElse: () => context.t.changelog.title,
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
                  children: Text(context.t.changelog.none),
                ),
              ),
            ],
          ),
          loading: () => Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Center(child: RefreshProgressIndicator()),
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
