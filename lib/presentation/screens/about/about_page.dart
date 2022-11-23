import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/constant/app.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/app_updater.dart';
import 'package:boorusphere/presentation/provider/app_versions/app_versions_state.dart';
import 'package:boorusphere/presentation/provider/changelog_state.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/widgets/download_dialog.dart';
import 'package:boorusphere/presentation/widgets/prepare_update.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/number.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersions = ref.watch(appVersionsStateProvider);

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
                child: appVersions.maybeWhen(
                  data: (data) {
                    return Text(
                      context.t.version(version: '${data.current} - $kAppArch'),
                      style: context.theme.textTheme.subtitle2
                          ?.copyWith(fontWeight: FontWeight.w400),
                    );
                  },
                  orElse: SizedBox.shrink,
                ),
              ),
              appVersions.when(
                data: (data) {
                  return data.latest.isNewerThan(data.current)
                      ? _Updater(data.latest)
                      : ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(appVersionsStateProvider);
                          },
                          style: ElevatedButton.styleFrom(elevation: 0),
                          icon: const Icon(Icons.done),
                          label: Text(context.t.updater.onLatest),
                        );
                },
                loading: () {
                  return ElevatedButton.icon(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(elevation: 0),
                    icon: Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(),
                    ),
                    label: Text(context.t.updater.checking),
                  );
                },
                error: (e, s) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(appVersionsStateProvider);
                    },
                    style: ElevatedButton.styleFrom(elevation: 0),
                    icon: const Icon(Icons.update),
                    label: Text(context.t.updater.check),
                  );
                },
              ),
              const Divider(height: 32),
              ListTile(
                title: Text(context.t.changelog.title),
                leading: const Icon(Icons.list_alt_rounded),
                onTap: () {
                  context.router.push(
                    ChangelogRoute(type: ChangelogType.assets),
                  );
                },
              ),
              ListTile(
                title: Text(context.t.github),
                leading: const FaIcon(FontAwesomeIcons.github),
                onTap: () {
                  launchUrlString(
                    VersionNetworkSource.gitUrl,
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                title: Text(context.t.ossLicense),
                leading: const Icon(Icons.collections_bookmark),
                onTap: () {
                  context.router.push(const LicensesRoute());
                },
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
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(context.t.updater.onNewVersion),
        ),
        _Downloader(version: data),
        ElevatedButton(
          onPressed: () {
            context.router.push(
              ChangelogRoute(type: ChangelogType.git, version: data),
            );
          },
          style: ElevatedButton.styleFrom(elevation: 0),
          child: Text(context.t.changelog.view),
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
    final progress = ref.watch(appUpdateProgressProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (progress.status.isCanceled ||
            progress.status.isFailed ||
            progress.status.isEmpty)
          ElevatedButton(
            onPressed: () async {
              if (!await checkNotificationPermission(context)) {
                return;
              }

              await ref.read(appUpdaterProvider).start(version);
            },
            style: ElevatedButton.styleFrom(elevation: 0),
            child: Text(context.t.updater.download(version: version)),
          ),
        if (progress.status.isDownloading) ...[
          const SizedBox(width: 16),
          Padding(
              padding: const EdgeInsets.all(8),
              child: Text('${progress.progress}%')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: progress.progress.ratio,
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
              ref.read(appUpdaterProvider).stop();
            },
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 16),
        ],
        if (progress.status.isDownloaded)
          ElevatedButton(
            onPressed: () {
              UpdatePrepareDialog.show(context);
            },
            child: Text(context.t.updater.install),
          ),
      ],
    );
  }
}
