import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/booru_post.dart';
import '../../provider/common.dart';
import '../components/tag.dart';
import 'home.dart';

class PostDetails extends HookWidget {
  const PostDetails({Key? keys, required this.id}) : super(key: keys);
  final int id;

  @override
  Widget build(BuildContext context) {
    final server = useProvider(serverProvider);
    final booruPosts = useProvider(booruPostsProvider);
    final selectedtag = useState(<String>[]);
    final api = useProvider(apiProvider);
    final searchTagHandler = useProvider(searchTagProvider.notifier);
    final fabController = useAnimationController(
        duration: const Duration(milliseconds: 150), initialValue: 0);

    final data = booruPosts.firstWhere(
      (element) => element.id == id,
      orElse: () => BooruPost.empty(),
    );
    final postUrl = server.active.composePostUrl(data.id);

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
                },
                tag: tag,
                active: () => selectedtag.value.contains(tag),
              );
            }).toList()),
          ),
          SizedBox.fromSize(size: const Size(0, 72)),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 64,
            child: ScaleTransition(
              scale: fabController,
              child: FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.search),
                onPressed: () {
                  final tags = selectedtag.value.join(' ');
                  if (tags.isNotEmpty) {
                    searchTagHandler.setTag(query: tags);
                    api.fetch(clear: true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ScaleTransition(
              scale: fabController,
              child: FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.copy),
                onPressed: () {
                  final tags = selectedtag.value.join(' ');
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
          ),
        ],
      ),
    );
  }
}
