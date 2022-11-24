import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class TimelineController extends ChangeNotifier {
  TimelineController({
    this.heroKeyBuilder,
    this.onLoadMore,
  }) {
    _scrollController.addListener(_autoLoadMore);
  }

  final Object Function(Post post)? heroKeyBuilder;
  final void Function()? onLoadMore;
  final _scrollController = AutoScrollController(axis: Axis.vertical);

  AutoScrollController get scrollController => _scrollController;

  void revealAt(int dest) {
    if (!scrollController.hasClients || scrollController.isAutoScrolling) {
      return;
    }

    if (scrollController.isIndexStateInLayoutRange(dest)) {
      scrollController.scrollToIndex(
        dest,
        duration: const Duration(milliseconds: 16),
        preferPosition: AutoScrollPosition.middle,
      );
    } else {
      scrollController
          .scrollToIndex(
            dest,
            duration: const Duration(milliseconds: 800),
            preferPosition: AutoScrollPosition.middle,
          )
          .whenComplete(() => scrollController.highlight(dest,
              highlightDuration: const Duration(milliseconds: 150)));
    }
  }

  void loadMoreData() {
    onLoadMore?.call();
  }

  void _autoLoadMore() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 200) {
      loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_autoLoadMore);
    super.dispose();
  }
}
