import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/booru_post.dart';
import '../containers/post_detail.dart';

class PostToolbox extends StatelessWidget {
  const PostToolbox(this.booru, {Key? key}) : super(key: key);

  final BooruPost booru;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      child: Card(
        margin: const EdgeInsets.fromLTRB(12, 12, 16, 20),
        color: Colors.black.withOpacity(0.6),
        elevation: 0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.link_outlined),
              onPressed: () => launch(booru.src),
              color: Colors.white,
            ),
            IconButton(
              icon: const Icon(Icons.info),
              color: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostDetails(data: booru)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
