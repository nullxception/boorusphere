import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../entity/app_version.dart';
import '../../services/download.dart';
import '../../source/changelog.dart';
import '../../source/version.dart';
import '../../utils/extensions/asyncvalue.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../app_router.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVer = ref.watch(versionCurrentProvider
        .select((it) => it.maybeValue ?? AppVersion.zero));
    final latestVer = ref.watch(versionLatestProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.onBackground,
                ),
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(
                  'assets/icons/exported/logo.png',
                  height: 48,
                ),
              ),
              Text(
                'Boorusphere',
                style: context.theme.textTheme.headline6
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Version $currentVer - ${VersionDataSource.arch}',
                  style: context.theme.textTheme.subtitle2
                      ?.copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              latestVer.when(
                data: (data) => data.isNewerThan(currentVer)
                    ? _Updater(data)
                    : ElevatedButton.icon(
                        onPressed: () => ref.refresh(versionLatestProvider),
                        style: ElevatedButton.styleFrom(elevation: 0),
                        icon: const Icon(Icons.done),
                        label: const Text('You\'re on latest version'),
                      ),
                loading: () => ElevatedButton.icon(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(elevation: 0),
                  icon: Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(),
                  ),
                  label: const Text('Checking for update...'),
                ),
                error: (e, s) => ElevatedButton.icon(
                  onPressed: () => ref.refresh(versionLatestProvider),
                  style: ElevatedButton.styleFrom(elevation: 0),
                  icon: const Icon(Icons.update),
                  label: const Text('Check for update'),
                ),
              ),
              const Divider(height: 32),
              ListTile(
                title: const Text('Changelog'),
                leading: const Icon(Icons.list_alt_rounded),
                onTap: () {
                  context.router.push(
                    ChangelogRoute(
                      option: const ChangelogOption(type: ChangelogType.assets),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('GitHub'),
                leading: const FaIcon(FontAwesomeIcons.github),
                onTap: () => launchUrlString(VersionDataSource.gitUrl,
                    mode: LaunchMode.externalApplication),
              ),
              ListTile(
                title: const Text('Open source licenses'),
                leading: const Icon(Icons.collections_bookmark),
                onTap: () => context.router.push(const LicensesRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Updater extends HookConsumerWidget {
  const _Updater(this.data);

  final AppVersion data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('New update is available'),
        ),
        _Downloader(version: data),
        ElevatedButton(
          onPressed: () {
            context.router.push(
              ChangelogRoute(
                option: ChangelogOption(
                  type: ChangelogType.git,
                  version: data,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(elevation: 0),
          child: const Text('View changes'),
        ),
      ],
    );
  }
}

class _Downloader extends HookConsumerWidget {
  const _Downloader({
    required this.version,
  });

  final AppVersion version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updater =
        ref.watch(downloadProvider.select((it) => it.appUpdateProgress));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (updater.status.isCanceled ||
            updater.status.isFailed ||
            updater.status.isEmpty)
          ElevatedButton(
            onPressed: () {
              ref
                  .read(downloadProvider)
                  .updater(action: UpdaterAction.start, version: version);
            },
            style: ElevatedButton.styleFrom(elevation: 0),
            child: Text('Download v$version'),
          ),
        if (updater.status.isDownloading) ...[
          const SizedBox(width: 16),
          Padding(
              padding: const EdgeInsets.all(8),
              child: Text('${updater.progress}%')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: updater.progress.ratio,
                    minHeight: 16,
                  ),
                  Shimmer(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.colorScheme.primary.withOpacity(0),
                        context.colorScheme.primary.withOpacity(0.5),
                        context.colorScheme.primary.withOpacity(0),
                      ],
                      stops: const <double>[
                        0.35,
                        0.5,
                        0.65,
                      ],
                    ),
                    period: const Duration(milliseconds: 700),
                    child: const LinearProgressIndicator(
                      value: 0,
                      minHeight: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(downloadProvider).updater(action: UpdaterAction.stop);
            },
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 16),
        ],
        if (updater.status.isDownloaded)
          ElevatedButton(
            onPressed: () {
              ref.read(downloadProvider).updater(action: UpdaterAction.install);
            },
            child: const Text('Install update'),
          ),
      ],
    );
  }
}
