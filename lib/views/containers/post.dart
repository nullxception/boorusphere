import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/common.dart';
import '../components/post_display.dart';
import '../components/post_toolbox.dart';
import '../components/preferred_visibility.dart';
import '../components/subbed_title.dart';

class Post extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final beginPage = ModalRoute.of(context)?.settings.arguments as int;

    final pageController = usePageController(initialPage: beginPage);
    final style = useProvider(styleProvider);
    final pageCache = useProvider(pageCacheProvider).state;
    final page = useState(beginPage);

    final isNotVideo = pageCache[page.value].displayType != PostType.video;

    useEffect(() {
      // reset fullscreen state when pop back to timeline
      return () {
        return style.resetSystemOverrides(notify: false);
      };
    }, const []);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredVisibility(
        visible: !style.isFullScreen,
        child: AppBar(
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
          title: SubbedTitle(
            title: '#${page.value + 1} of ${pageCache.length}',
            subtitle: pageCache[page.value].tags.join(' '),
          ),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (index) => page.value = index,
        itemCount: pageCache.length,
        itemBuilder: (_, index) => PostDisplay(content: pageCache[index]),
      ),
      bottomNavigationBar: Visibility(
        visible: !style.isFullScreen && isNotVideo,
        child: PostToolbox(pageCache[page.value]),
      ),
    );
  }
}
