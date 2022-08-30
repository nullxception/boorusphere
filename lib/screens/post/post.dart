import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../entity/post.dart';
import '../../../hooks/extended_page_controller.dart';
import '../../services/fullscreen.dart';
import '../../source/page.dart';
import '../../utils/extensions/asyncvalue.dart';
import '../../widgets/styled_overlay_region.dart';
import 'appbar_visibility.dart';
import 'post_error.dart';
import 'post_image.dart';
import 'post_toolbox.dart';
import 'post_video.dart';

class PostPage extends HookConsumerWidget {
  const PostPage({
    super.key,
    required this.beginPage,
    this.posts = const [],
    this.onReturned,
    this.onLoadMore,
    this.heroPrefix = '',
  });

  final int beginPage;
  final void Function(int)? onReturned;
  final List<Post> posts;
  final void Function()? onLoadMore;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadMoreThreshold = 90;
    final page = useState(beginPage);
    final pageController = useExtendedPageController(initialPage: page.value);
    final pageState = ref.watch(pageStateProvider);
    final fullscreen = ref.watch(fullscreenProvider);
    final appbarAnimController =
        useAnimationController(duration: const Duration(milliseconds: 300));

    final post = posts.isEmpty ? Post.empty : posts[page.value];
    final isVideo = post.contentType == PostType.video;
    final totalPost = posts.length;

    return WillPopScope(
      onWillPop: () async {
        onReturned?.call(page.value);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StyledOverlayRegion(
          nightMode: true,
          child: Stack(
            children: [
              Padding(
                // android back gesture is not ignored by PageView
                // add tiny padding to avoid it
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: ExtendedImageGesturePageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    page.value = index;
                    final offset = index + 1;
                    final threshold =
                        totalPost / 100 * (100 - loadMoreThreshold);
                    if (offset + threshold > totalPost) {
                      onLoadMore?.call();
                    }
                  },
                  itemCount: totalPost,
                  itemBuilder: (_, index) {
                    final post = posts[index];
                    final Widget widget;
                    final heroKey = '$heroPrefix-${post.id}';
                    switch (post.contentType) {
                      case PostType.photo:
                        widget = PostImageDisplay(
                          post: post,
                          isFromHome: index == beginPage,
                          heroKey: heroKey,
                        );
                        break;
                      case PostType.video:
                        widget = PostVideoDisplay(
                          post: post,
                          heroKey: heroKey,
                        );
                        break;
                      default:
                        widget = PostErrorDisplay(
                          post: post,
                          heroKey: heroKey,
                        );
                        break;
                    }
                    return HeroMode(
                      enabled: index == page.value,
                      child: widget,
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppbarVisibility(
                  controller: appbarAnimController,
                  visible: !fullscreen,
                  child: _PostAppBar(
                    subtitle: post.tags.join(' '),
                    title: pageState.isLoading
                        ? '#${page.value + 1} of (loading...)'
                        : '#${page.value + 1} of ${posts.length}',
                  ),
                ),
              ),
              if (!isVideo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomBarVisibility(
                    controller: appbarAnimController,
                    visible: !fullscreen,
                    child: PostToolbox(post),
                  ),
                ),
            ],
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
