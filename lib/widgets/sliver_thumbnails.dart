import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../data/post.dart';
import '../../providers/page_manager.dart';
import '../../providers/settings/blur_explicit_post.dart';
import '../../providers/settings/grid.dart';
import '../../routes.dart';
import '../../screens/post.dart';

class SliverThumbnails extends HookConsumerWidget {
  final AutoScrollController autoScrollController;

  const SliverThumbnails({super.key, required this.autoScrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridExtra = ref.watch(gridProvider);
    final lastOpenedIndex = ref.watch(lastOpenedPostProvider.state);
    final pageManager = ref.watch(pageManagerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    return SliverMasonryGrid.count(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childCount: pageManager.posts.length,
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
            child: Thumbnail(post: pageManager.posts[index]),
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
    );
  }
}

class Thumbnail extends HookConsumerWidget {
  const Thumbnail({super.key, required this.post});
  final Post post;

  FilterQuality _thumbnailQuality(int gridExtra) {
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
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);

    return ExtendedImage.network(
      post.previewFile,
      filterQuality: _thumbnailQuality(gridExtra),
      fit: BoxFit.fill,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _ThumbnailShimmer(aspectRatio: post.aspectRatio);
          case LoadState.failed:
            return Material(
              child: AspectRatio(
                aspectRatio: post.aspectRatio,
                child: const Icon(Icons.broken_image_outlined),
              ),
            );
          default:
            return blurExplicitPost && post.rating == PostRating.explicit
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 8,
                      sigmaY: 8,
                      tileMode: TileMode.decal,
                    ),
                    child: state.completedWidget,
                  )
                : state.completedWidget;
        }
      },
    );
  }
}

class _ThumbnailShimmer extends StatelessWidget {
  const _ThumbnailShimmer({required this.aspectRatio});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.light
        ? theme.colorScheme.background.desaturate(50).darken(2)
        : theme.colorScheme.surface;
    final highlightColor = theme.brightness == Brightness.light
        ? theme.colorScheme.background.desaturate(50).lighten(2)
        : theme.colorScheme.surface.lighten(5);

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
