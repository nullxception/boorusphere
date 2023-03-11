import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/fullscreen_state.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/presentation/screens/post/post_image.dart';
import 'package:boorusphere/presentation/screens/post/post_toolbox.dart';
import 'package:boorusphere/presentation/screens/post/post_unknown.dart';
import 'package:boorusphere/presentation/screens/post/post_video.dart';
import 'package:boorusphere/presentation/utils/entity/content.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/utils/hooks/extended_page_controller.dart';
import 'package:boorusphere/presentation/widgets/slidefade_visibility.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wakelock/wakelock.dart';

final postPageArgsProvider =
    Provider.autoDispose<PageArgs>((ref) => throw UnimplementedError());

class PostPage extends HookConsumerWidget {
  const PostPage({
    super.key,
    required this.beginPage,
    required this.posts,
    required this.timelineController,
    this.heroTagBuilder,
  });

  final int beginPage;
  final Iterable<Post> posts;
  final Object Function(Post)? heroTagBuilder;
  final TimelineController timelineController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadMoreThreshold = 90;
    final currentPage = useState(beginPage);
    final pageController =
        useExtendedPageController(initialPage: currentPage.value);
    final fullscreen = ref.watch(fullscreenStateProvider);

    final post =
        posts.isEmpty ? Post.empty : posts.elementAt(currentPage.value);
    final showAppbar = useState(true);
    final isLoadingMore = useState(false);
    final loadMore = timelineController.onLoadMore;

    useEffect(() {
      showAppbar.value = !fullscreen;
    }, [fullscreen]);

    useEffect(() {
      Wakelock.enable();
      return Wakelock.disable;
    }, []);

    return ProviderScope(
      overrides: [
        postPageArgsProvider.overrideWith((ref) => timelineController.pageArgs)
      ],
      child: WillPopScope(
        onWillPop: () async {
          ref.watch(fullscreenStateProvider.notifier).reset();
          context.scaffoldMessenger.removeCurrentSnackBar();
          timelineController.revealAt(currentPage.value);
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: StyledOverlayRegion(
            nightMode: true,
            child: Stack(
              children: [
                ExtendedImageGesturePageView.builder(
                  controller: pageController,
                  onPageChanged: (index) async {
                    currentPage.value = index;
                    context.scaffoldMessenger.hideCurrentSnackBar();
                    if (loadMore == null) return;

                    final offset = index + 1;
                    final threshold =
                        posts.length / 100 * (100 - loadMoreThreshold);
                    if (offset + threshold > posts.length - 1) {
                      isLoadingMore.value = true;
                      await loadMore();
                      await Future.delayed(kThemeAnimationDuration, () {
                        isLoadingMore.value = false;
                      });
                    }
                  },
                  preloadPagesCount: 1,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts.elementAt(index);
                    final heroTag = heroTagBuilder?.call(post);
                    final Widget widget;
                    switch (post.content.type) {
                      case PostType.photo:
                        widget = PostImage(post: post, heroTag: heroTag);
                        break;
                      case PostType.video:
                        widget = PostVideo(
                          post: post,
                          heroTag: heroTag,
                          active: currentPage.value == index,
                          onToolboxVisibilityChange: (visible) {
                            showAppbar.value = visible;
                          },
                        );
                        break;
                      default:
                        widget = PostUnknown(post: post, heroTag: heroTag);
                        break;
                    }
                    return ColoredBox(
                      color: Colors.black,
                      child: HeroMode(
                        enabled: index == currentPage.value,
                        child: widget,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SlideFadeVisibility(
                    direction: HidingDirection.toTop,
                    visible: showAppbar.value,
                    child: _PostAppBar(
                      subtitle: post.describeTags,
                      title: isLoadingMore.value
                          ? '#${currentPage.value + 1} of (loading...)'
                          : '#${currentPage.value + 1} of ${posts.length}',
                    ),
                  ),
                ),
                if (!post.content.isVideo)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SlideFadeVisibility(
                      direction: HidingDirection.toBottom,
                      visible: !fullscreen,
                      child: PostToolbox(post),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PostAppBar({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 64);
}
