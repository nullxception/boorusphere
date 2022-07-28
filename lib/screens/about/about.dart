import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../providers/app_version.dart';
import '../../utils/extensions/buildcontext.dart';
import '../routes.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
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
                'Version ${version.version} - ${version.variant}',
                style: context.theme.textTheme.subtitle2
                    ?.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
            if (version.shouldUpdate && version.isChecked)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('New update is available'),
                  ),
                  ElevatedButton(
                    onPressed: () => launchUrlString(version.apkUrl,
                        mode: LaunchMode.externalApplication),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    child: Text('Download v${version.lastestVersion}'),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: version.checkForUpdate,
                style: ElevatedButton.styleFrom(elevation: 0),
                icon: version.isChecking
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(),
                      )
                    : Icon(
                        !version.shouldUpdate && version.isChecked
                            ? Icons.done
                            : Icons.update,
                      ),
                label: Text(
                  !version.shouldUpdate && version.isChecked
                      ? 'You\'re on latest version'
                      : 'Check for update',
                ),
              ),
            const Divider(height: 32),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('GitHub'),
              leading: const FaIcon(FontAwesomeIcons.github),
              onTap: () => launchUrlString(AppVersionManager.gitUrl,
                  mode: LaunchMode.externalApplication),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Open source licenses'),
              leading: const Icon(Icons.collections_bookmark),
              onTap: () => Navigator.pushNamed(context, Routes.licenses),
            ),
          ],
        ),
      ),
    );
  }
}
