import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/common.dart';
import '../../routes.dart';

class SliverThumbnails extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final gridExtra = useProvider(gridProvider);
    final booruPosts = useProvider(booruPostsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: booruPosts.length,
      itemBuilder: (context, index) => GestureDetector(
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: CachedNetworkImage(
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 500),
            filterQuality: FilterQuality.none,
            fit: BoxFit.fill,
            imageUrl: booruPosts[index].thumbnail,
            progressIndicatorBuilder: (_, __, ___) => AspectRatio(
              aspectRatio: booruPosts[index].width / booruPosts[index].height,
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: LinearProgressIndicator()),
              ),
            ),
            errorWidget: (_, __, error) =>
                const Icon(Icons.broken_image_outlined),
          ),
        ),
        onTap: () =>
            Navigator.pushNamed(context, Routes.post, arguments: index),
      ),
      staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
    );
  }
}
