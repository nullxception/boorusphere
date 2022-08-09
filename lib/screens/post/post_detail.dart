import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../entity/page_option.dart';
import '../../source/blocked_tags.dart';
import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/string.dart';
import '../../widgets/styled_overlay_region.dart';
import '../home/home.dart';
import 'tag.dart';

class PostDetailsPage extends HookConsumerWidget {
  const PostDetailsPage({super.key, required this.post});
  final Post post;

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedtag = useState(<String>[]);
    final pageQuery =
        ref.watch(pageOptionProvider.select((value) => value.query));
    final blockedTagsHandler = ref.watch(blockedTagsProvider);
    final fabController = useAnimationController(
        duration: const Duration(milliseconds: 250), initialValue: 0);
    final showFAB = useState(false);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: StyledOverlayRegion(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 72),
            children: [
              ListTile(
                title: const Text('Rating'),
                subtitle: Text(post.rating.name.capitalized),
              ),
              if (post.postUrl.isNotEmpty)
                ListTile(
                  title: const Text('Location'),
                  subtitle: TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerLeft,
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero,
                      ),
                    ),
                    onPressed: () => launchUrlString(post.postUrl,
                        mode: LaunchMode.externalApplication),
                    child: Text(post.postUrl.toString()),
                  ),
                  trailing: IconButton(
                    iconSize: 18,
                    onPressed: () {
                      copyToClipboard(context, post.postUrl.toString());
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ),
              if (post.source.isNotEmpty)
                ListTile(
                  title: const Text('Source'),
                  subtitle: TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.centerLeft,
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.zero,
                      ),
                    ),
                    onPressed: () => launchUrlString(post.source,
                        mode: LaunchMode.externalApplication),
                    child: Text(post.source.toString()),
                  ),
                  trailing: IconButton(
                    iconSize: 18,
                    onPressed: () {
                      copyToClipboard(context, post.source.toString());
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ),
              if (post.sampleFile.isNotEmpty)
                ListTile(
                  title: const Text('Sample file (displayed)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            '${post.sampleSize.toString()}, ${post.sampleFile.fileExtension}'),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          alignment: Alignment.centerLeft,
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.zero,
                          ),
                        ),
                        onPressed: () => launchUrlString(post.sampleFile,
                            mode: LaunchMode.externalApplication),
                        child: Text(post.sampleFile),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    iconSize: 18,
                    onPressed: () {
                      copyToClipboard(context, post.sampleFile);
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ),
              ListTile(
                title: const Text('Original file'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                          '${post.originalSize.toString()}, ${post.originalFile.fileExtension}'),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        alignment: Alignment.centerLeft,
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.zero,
                        ),
                      ),
                      onPressed: () => launchUrlString(post.originalFile,
                          mode: LaunchMode.externalApplication),
                      child: Text(post.originalFile),
                    ),
                  ],
                ),
                trailing: IconButton(
                  iconSize: 18,
                  onPressed: () {
                    copyToClipboard(context, post.originalFile);
                  },
                  icon: const Icon(Icons.copy),
                ),
              ),
              const ListTile(
                title: Text('Tags'),
              ),
              ListTile(
                title: Wrap(
                    children: post.tags.map((tag) {
                  return Tag(
                    onPressed: () {
                      if (!selectedtag.value.contains(tag)) {
                        // display FAB on first select
                        if (selectedtag.value.isEmpty) {
                          fabController.forward();
                        }
                        selectedtag.value.add(tag);
                      } else {
                        selectedtag.value.remove(tag);
                        // display FAB on last removal
                        if (selectedtag.value.isEmpty) {
                          fabController.reverse();
                        }
                      }

                      showFAB.value = selectedtag.value.isNotEmpty;
                    },
                    tag: tag,
                    active: () => selectedtag.value.contains(tag),
                  );
                }).toList()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.tag,
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
        visible: showFAB.value,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: 'Copy tag',
              onTap: () {
                final tags = selectedtag.value.join(' ');
                if (tags.isNotEmpty) {
                  copyToClipboard(context, tags);
                }
              }),
          SpeedDialChild(
            child: const Icon(Icons.block),
            label: 'Block selected tag',
            onTap: () {
              final selectedTags = selectedtag.value;
              if (selectedTags.isNotEmpty) {
                blockedTagsHandler.pushAll(selectedTags);
                context.scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Added to tags blocker list'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: 'Add tag to current search',
            onTap: () {
              final selectedTags = selectedtag.value;
              if (selectedTags.isNotEmpty) {
                final tags = Set<String>.from(pageQuery.split(' '));
                tags.addAll(selectedTags);
                ref.read(pageOptionProvider.notifier).update(
                    (state) => PageOption(query: tags.join(' '), clear: true));
                context.navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: 'Search tag',
            onTap: () {
              final tags = selectedtag.value.join(' ');
              if (tags.isNotEmpty) {
                ref
                    .read(pageOptionProvider.notifier)
                    .update((state) => PageOption(query: tags, clear: true));
                context.navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
