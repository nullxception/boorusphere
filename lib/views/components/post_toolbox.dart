import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/booru_post.dart';
import '../containers/post_detail.dart';

class PostToolbox extends StatelessWidget {
  const PostToolbox(this.booru, {Key? key}) : super(key: key);

  final BooruPost booru;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.link_outlined),
            onPressed: () => launchUrlString(booru.src,
                mode: LaunchMode.externalApplication),
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.info),
            color: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetails(id: booru.id)),
            ),
          ),
        ],
      ),
    );
  }
}
