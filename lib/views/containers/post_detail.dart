import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/booru_post.dart';
import '../../provider/booru_api.dart';
import '../../provider/booru_query.dart';
import '../../provider/server_data.dart';
import '../components/tag.dart';
import 'home.dart';

class PostDetails extends HookConsumerWidget {
  const PostDetails({Key? keys, required this.id}) : super(key: keys);
  final int id;

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverDataProvider);
    final selectedtag = useState(<String>[]);
    final api = ref.watch(booruApiProvider);
    final booruQueryNotifier = ref.watch(booruQueryProvider.notifier);
    final fabController = useAnimationController(
        duration: const Duration(milliseconds: 150), initialValue: 0);
    var showFAB = useState(false);
    final data = api.posts.firstWhere(
      (element) => element.id == id,
      orElse: () => BooruPost.empty(),
    );
    final postUrl = server.active.composePostUrl(data.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Size'),
            subtitle: Text('${data.width}x${data.height}'),
          ),
          ListTile(
            title: const Text('Type'),
            subtitle: Text(data.mimeType),
          ),
          if (postUrl != null)
            ListTile(
              title: const Text('Location'),
              subtitle: TextButton(
                style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.zero,
                  ),
                ),
                onPressed: () => launch(postUrl.toString()),
                child: Text(postUrl.toString()),
              ),
              trailing: IconButton(
                iconSize: 18,
                onPressed: () {
                  copyToClipboard(context, postUrl.toString());
                },
                icon: const Icon(Icons.copy),
              ),
            ),
          ListTile(
            title: const Text('Source'),
            subtitle: TextButton(
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
              ),
              onPressed: () => launch(data.src),
              child: Text(data.src),
            ),
            trailing: IconButton(
              iconSize: 18,
              onPressed: () {
                copyToClipboard(context, data.src);
              },
              icon: const Icon(Icons.copy),
            ),
          ),
          if (data.displaySrc != data.src)
            ListTile(
              title: const Text('Source (displayed)'),
              subtitle: TextButton(
                style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.zero,
                  ),
                ),
                onPressed: () => launch(data.displaySrc),
                child: Text(data.displaySrc),
              ),
            ),
          const ListTile(
            title: Text('Tags'),
          ),
          ListTile(
            title: Wrap(
                children: data.tags.map((tag) {
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
        icon: Icons.menu,
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
            child: const Icon(Icons.search),
            label: 'Search it',
            onTap: () {
              final tags = selectedtag.value.join(' ');
              if (tags.isNotEmpty) {
                booruQueryNotifier.setTag(query: tags);
                api.posts.clear();
                api.fetch();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
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
