import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../provider/common.dart';
import '../../routes.dart';

class SliverThumbnails extends HookWidget {
  final AutoScrollController autoScrollController;

  SliverThumbnails({Key? key, required this.autoScrollController})
      : super(key: key);

  FilterQuality thumbnailQuality(int gridExtra) {
    switch (gridExtra) {
      case 0:
        return FilterQuality.medium;
      case 1:
        return FilterQuality.low;
      default:
        return FilterQuality.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridExtra = useProvider(gridProvider);
    final lastOpenedIndex = useProvider(lastOpenedPostProvider);
    final booruPosts = useProvider(booruPostsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: booruPosts.length,
      itemBuilder: (context, index) => AutoScrollTag(
        key: ValueKey(index),
        controller: autoScrollController,
        index: index,
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: GestureDetector(
            child: CachedNetworkImage(
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 500),
              filterQuality: thumbnailQuality(gridExtra),
              fit: BoxFit.fill,
              imageUrl: booruPosts[index].thumbnail,
              progressIndicatorBuilder: (_, __, ___) => AspectRatio(
                aspectRatio: booruPosts[index].width / booruPosts[index].height,
                child: const Align(
                  child: LinearProgressIndicator(),
                  alignment: Alignment.bottomCenter,
                ),
              ),
              errorWidget: (_, __, error) =>
                  const Icon(Icons.broken_image_outlined),
            ),
            onTap: () {
              // invalidate the state first so we can use it for checking mechanism too
              lastOpenedIndex.state = -1;
              Navigator.pushNamed(context, Routes.post, arguments: index)
                  .then((_) {
                // don't scroll it unless it's mutated (by PageView's onPageChanged)
                if (lastOpenedIndex.state != -1) {
                  autoScrollController.scrollToIndex(
                    lastOpenedIndex.state,
                    duration: const Duration(milliseconds: 600),
                    preferPosition: AutoScrollPosition.middle,
                  );
                }
              });
            },
          ),
        ),
      ),
      staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
    );
  }
}
