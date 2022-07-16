import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/downloader.dart';
import 'post_detail.dart';

class DownloadsPage extends HookConsumerWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'clear-all':
                  downloader.clearAllTask();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'clear-all',
                  child: Text('Clear all'),
                )
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...downloader.entries.map((it) {
              return ListTile(
                title: Text(downloader.getFileNameFromUrl(it.booru.src)),
                subtitle: Text(it.booru.serverName),
                leading: Icon(it.booru.displayType == PostType.video
                    ? Icons.video_library
                    : Icons.photo),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 'clear':
                        downloader.clearTask(id: it.id);
                        break;
                      case 'show-detail':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PostDetails(booru: it.booru)),
                        );
                        break;
                      default:
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'show-detail',
                        child: Text('Show detail'),
                      ),
                      const PopupMenuItem(
                        value: 'clear',
                        child: Text('Clear'),
                      ),
                    ];
                  },
                ),
                dense: true,
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                onTap: null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
