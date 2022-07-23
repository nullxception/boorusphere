import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/booru_post.dart';
import '../../model/server_data.dart';
import '../../provider/blocked_tags.dart';
import '../../provider/booru_api.dart';
import '../../provider/booru_query.dart';
import '../../util/string_ext.dart';
import '../components/tag.dart';
import 'home.dart';

class PostDetailsPage extends HookConsumerWidget {
  const PostDetailsPage({super.key, required this.booru});
  final BooruPost booru;

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedtag = useState(<String>[]);
    final api = ref.watch(booruApiProvider);
    final booruQuery = ref.watch(booruQueryProvider);
    final booruQueryNotifier = ref.watch(booruQueryProvider.notifier);
    final blockedTagsHandler = ref.watch(blockedTagsProvider);
    final fabController = useAnimationController(
        duration: const Duration(milliseconds: 250), initialValue: 0);
    final showFAB = useState(false);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: const Text('Size'),
            subtitle: Text('${booru.width}x${booru.height}'),
          ),
          ListTile(
            title: const Text('Type'),
            subtitle: Text(booru.contentFile.mimeType),
          ),
          ListTile(
            title: const Text('Rating'),
            subtitle: Text(booru.rating.name),
          ),
          if (booru.postUrl.isNotEmpty)
            ListTile(
              title: const Text('Location'),
              subtitle: TextButton(
                style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.zero,
                  ),
                ),
                onPressed: () => launchUrlString(booru.postUrl,
                    mode: LaunchMode.externalApplication),
                child: Text(booru.postUrl.toString()),
              ),
              trailing: IconButton(
                iconSize: 18,
                onPressed: () {
                  copyToClipboard(context, booru.postUrl.toString());
                },
                icon: const Icon(Icons.copy),
              ),
            ),
          if (booru.sampleFile.isNotEmpty)
            ListTile(
              title: const Text('Sample file (displayed)'),
              subtitle: TextButton(
                style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.zero,
                  ),
                ),
                onPressed: () => launchUrlString(booru.sampleFile,
                    mode: LaunchMode.externalApplication),
                child: Text(booru.sampleFile),
              ),
              trailing: IconButton(
                iconSize: 18,
                onPressed: () {
                  copyToClipboard(context, booru.sampleFile);
                },
                icon: const Icon(Icons.copy),
              ),
            ),
          ListTile(
            title: const Text('Original file'),
            subtitle: TextButton(
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
              ),
              onPressed: () => launchUrlString(booru.originalFile,
                  mode: LaunchMode.externalApplication),
              child: Text(booru.originalFile),
            ),
            trailing: IconButton(
              iconSize: 18,
              onPressed: () {
                copyToClipboard(context, booru.originalFile);
              },
              icon: const Icon(Icons.copy),
            ),
          ),
          const ListTile(
            title: Text('Tags'),
          ),
          ListTile(
            title: Wrap(
                children: booru.tags.map((tag) {
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
          SizedBox.fromSize(size: const Size(0, 72)),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.tag,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to tags blocker list'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          if (booruQuery.tags != ServerData.defaultTag)
            SpeedDialChild(
              child: const Icon(Icons.search),
              label: 'Add tag to current search',
              onTap: () {
                final selectedTags = selectedtag.value;
                if (selectedTags.isNotEmpty) {
                  final tags = Set<String>.from(booruQuery.tags.split(' '));
                  tags.addAll(selectedTags);
                  booruQueryNotifier.setTag(query: tags.join(' '));
                  api.posts.clear();
                  api.fetch();
                  Navigator.pushAndRemoveUntil(
                    context,
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
                booruQueryNotifier.setTag(query: tags);
                api.posts.clear();
                api.fetch();
                Navigator.pushAndRemoveUntil(
                  context,
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
