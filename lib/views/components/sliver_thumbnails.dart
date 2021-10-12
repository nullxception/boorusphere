import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';

import '../../provider/booru_api.dart';
import '../../provider/grid.dart';
import '../../routes.dart';
import '../containers/post.dart';

class SliverThumbnails extends HookConsumerWidget {
  final AutoScrollController autoScrollController;

  const SliverThumbnails({Key? key, required this.autoScrollController})
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
  Widget build(BuildContext context, WidgetRef ref) {
    final gridExtra = ref.watch(gridProvider);
    final lastOpenedIndex = ref.watch(lastOpenedPostProvider);
    final api = ref.watch(booruApiProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: api.posts.length,
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
              imageUrl: api.posts[index].thumbnail,
              progressIndicatorBuilder: (_, __, ___) => _ThumbnailShimmer(
                aspectRatio: api.posts[index].width / api.posts[index].height,
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

class _ThumbnailShimmer extends StatelessWidget {
  const _ThumbnailShimmer({
    Key? key,
    required this.aspectRatio,
  }) : super(key: key);

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;
    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.grey.shade500;

    return Shimmer(
      gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            baseColor,
            baseColor,
            highlightColor,
            baseColor,
            baseColor
          ],
          stops: const <double>[
            0.0,
            0.35,
            0.5,
            0.65,
            1.0
          ]),
      period: const Duration(milliseconds: 700),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(color: Colors.black, child: const SizedBox.expand()),
      ),
    );
  }
}
