import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../entity/post.dart';
import '../../../hooks/extended_page_controller.dart';
import '../../services/app_theme/app_theme.dart';
import '../../services/fullscreen.dart';
import '../../source/page.dart';
import '../../widgets/systemuistyle.dart';
import 'appbar_visibility.dart';
import 'post_error.dart';
import 'post_image.dart';
import 'post_toolbox.dart';
import 'post_video.dart';

final lastOpenedPostProvider = StateProvider((_) => -1);

class PostPage extends HookConsumerWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadMoreThreshold = 90;
    final beginPage = ModalRoute.of(context)?.settings.arguments as int;
    final pageController = useExtendedPageController(initialPage: beginPage);
    final pageData = ref.watch(pageDataProvider);
    final pageLoading = ref.watch(pageLoadingProvider);
    final page = useState(beginPage);
    final fullscreen = ref.watch(fullscreenProvider);
    final appbarAnimController =
        useAnimationController(duration: const Duration(milliseconds: 300));
    final isVideo = pageData.posts[page.value].contentType == PostType.video;
    final totalPost = pageData.posts.length;

    return Theme(
      data: ref.read(appThemeProvider).data.night,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppbarVisibility(
          controller: appbarAnimController,
          visible: !fullscreen,
          child: _PostAppBar(
            subtitle: pageData.posts[page.value].tags.join(' '),
            title: pageLoading
                ? '#${page.value + 1} of (loading...)'
                : '#${page.value + 1} of ${pageData.posts.length}',
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, page.value);
            return false;
          },
          child: SystemUIStyle(
            nightMode: true,
            child: Padding(
              // android back gesture is not ignored by PageView
              // add tiny padding to avoid it
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: ExtendedImageGesturePageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  page.value = index;
                  final threshold = totalPost / 100 * (100 - loadMoreThreshold);
                  if (totalPost - threshold < index) {
                    pageData.loadMore();
                  }
                },
                itemCount: totalPost,
                itemBuilder: (_, index) {
                  final post = pageData.posts[index];

                  switch (post.contentType) {
                    case PostType.photo:
                      return PostImageDisplay(post: post);
                    case PostType.video:
                      return PostVideoDisplay(post: post);
                    default:
                      return PostErrorDisplay(post: post);
                  }
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: !isVideo
            ? BottomBarVisibility(
                controller: appbarAnimController,
                visible: !fullscreen,
                child: PostToolbox(pageData.posts[page.value]),
              )
            : null,
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
