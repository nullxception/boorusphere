import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/booru_post.dart';
import '../../provider/common.dart';

final _selectedTagProvider = Provider.autoDispose<List<String>>((_) => []);

class PostDetails extends HookWidget {
  const PostDetails({Key? keys, required this.data}) : super(key: keys);
  final BooruPost data;

  @override
  Widget build(BuildContext context) {
    final activeServer = useProvider(activeServerProvider);
    final selectedtag = useProvider(_selectedTagProvider);
    final fabController = useAnimationController(
        duration: const Duration(milliseconds: 300), initialValue: 0);

    final postUrl = activeServer.composePostUrl(data.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
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
          ),
          const ListTile(
            title: Text('Tags'),
          ),
          ListTile(
            title: Tags(
              alignment: WrapAlignment.start,
              itemCount: data.tags.length,
              itemBuilder: (index) {
                final tag = data.tags[index];
                return ItemTags(
                  active: selectedtag.contains(tag),
                  title: tag,
                  index: index,
                  onPressed: (it) {
                    if (it.active ?? false) {
                      // display FAB on first select
                      if (selectedtag.isEmpty) {
                        fabController.forward();
                      }
                      selectedtag.add(tag);
                    } else if (it.active == false) {
                      selectedtag.remove(tag);
                      // display FAB on last removal
                      if (selectedtag.isEmpty) {
                        fabController.reverse();
                      }
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: fabController,
        child: FloatingActionButton(
          child: const Icon(Icons.copy),
          onPressed: () {
            final tags = selectedtag.join(' ');
            if (tags.isNotEmpty) {
              Clipboard.setData(
                ClipboardData(text: tags),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard:\n$tags'),
                  duration: const Duration(milliseconds: 600),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
