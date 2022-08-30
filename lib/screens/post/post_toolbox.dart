import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../routes/routes.dart';
import '../../services/download.dart';
import '../../source/favorites.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../../widgets/download_dialog.dart';

class PostToolbox extends HookConsumerWidget {
  const PostToolbox(this.post, {super.key});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewPadding = context.mediaQuery.viewPadding;
    final safePaddingBottom = useState(viewPadding.bottom);
    if (viewPadding.bottom > safePaddingBottom.value) {
      safePaddingBottom.value = viewPadding.bottom;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      height: safePaddingBottom.value + 86,
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(bottom: safePaddingBottom.value + 8, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PostFavoriteButton(post: post),
          PostDownloadButton(post: post),
          PostOpenLinkButton(post: post),
          PostDetailsButton(post: post),
        ],
      ),
    );
  }
}

class PostDetailsButton extends StatelessWidget {
  const PostDetailsButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      icon: const Icon(Icons.info),
      onPressed: () => context.router.push(PostDetailsRoute(post: post)),
    );
  }
}

class PostOpenLinkButton extends StatelessWidget {
  const PostOpenLinkButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      icon: const Icon(Icons.link_outlined),
      onPressed: () => launchUrlString(post.originalFile,
          mode: LaunchMode.externalApplication),
    );
  }
}

class FavoriteSnackbar extends StatelessWidget {
  const FavoriteSnackbar({super.key, required this.isAdded});

  final bool isAdded;

  @override
  Widget build(BuildContext context) {
    final bottomSafe =
        context.mediaQuery.viewPadding.bottom + kBottomNavigationBarHeight;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.theme.snackBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            margin: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_outline, size: 16),
                const SizedBox(width: 8),
                Text(isAdded ? 'Added to Favorites' : 'Removed from Favorites'),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        context.scaffoldMessenger.hideCurrentSnackBar();
      },
    );
  }

  static void show({required BuildContext context, required bool isAdded}) {
    context.scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: FavoriteSnackbar(isAdded: isAdded),
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class PostFavoriteButton extends ConsumerWidget {
  const PostFavoriteButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesProvider);
    final isFavorite = ref.watch(favoritesProvider.notifier).checkExists(post);

    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      icon: AnimatedSwitcher(
        duration: kThemeChangeDuration,
        child: isFavorite
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
      ),
      onPressed: () {
        if (isFavorite) {
          ref.watch(favoritesProvider.notifier).delete(post);
          FavoriteSnackbar.show(context: context, isAdded: false);
        } else {
          ref.watch(favoritesProvider.notifier).save(post);
          FavoriteSnackbar.show(context: context, isAdded: true);
        }
      },
    );
  }
}

class PostDownloadButton extends HookConsumerWidget {
  const PostDownloadButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByPost(post);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: downloadProgress.status.isDownloading
              ? downloadProgress.progress.ratio
              : 0,
        ),
        IconButton(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          icon: Icon(downloadProgress.status.isDownloaded
              ? Icons.download_done
              : Icons.download),
          onPressed: () {
            DownloaderDialog.show(context: context, post: post);
          },
          disabledColor: context.colorScheme.primary,
        ),
      ],
    );
  }
}
