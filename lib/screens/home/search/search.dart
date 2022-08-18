import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../entity/page_option.dart';
import '../../../source/page.dart';
import '../../../source/search_history.dart';
import '../../../source/settings/grid.dart';
import '../../../source/settings/server/active.dart';
import '../../../source/suggestion.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/extensions/string.dart';
import '../../../widgets/exception_info.dart';
import '../../../widgets/favicon.dart';
import '../home.dart';

part 'controller.dart';
part 'searchbar.dart';
part 'suggestion.dart';

class SearchableView extends HookConsumerWidget {
  const SearchableView({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(searchBarController.select((it) => it.isOpen));
    final animator =
        useAnimationController(duration: const Duration(milliseconds: 300));
    final animation =
        CurvedAnimation(parent: animator, curve: Curves.easeInOutCubic);

    useEffect(() {
      isOpen ? animator.forward() : animator.reverse();
    }, [isOpen]);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FadeTransition(
          opacity: Tween<double>(
            begin: 0.5,
            end: 1,
          ).animate(animation),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: const _SearchSuggestion(),
          ),
        ),
        _SearchBar(scrollController: scrollController),
      ],
    );
  }
}
