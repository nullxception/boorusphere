import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/provider/booru/suggestion_state.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchBarControllerProvider =
    ChangeNotifierProvider.autoDispose<SearchBarController>(
        (ref) => throw UnimplementedError());

class SearchBarController extends ChangeNotifier {
  SearchBarController(this.ref, {required this.session}) {
    textEditingController
      ..addListener(_fetch)
      ..addListener(notifyListeners);
  }

  final Ref ref;
  final SearchSession session;

  late final textEditingController = TextEditingController(text: initial);

  Timer? _textTimer;
  bool _open = false;

  bool get isOpen => _open;
  String get value => textEditingController.value.text;
  String get initial => session.query;

  set _value(String value) {
    textEditingController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange(start: value.length, end: value.length),
    );
  }

  _fetch() {
    if (!isOpen) return;
    if (_textTimer?.isActive ?? false) _textTimer?.cancel();
    _textTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(suggestionStateProvider.notifier).get(value);
    });
  }

  void submit(BuildContext context, String newValue) {
    _value = initial;
    close();
    context.router.push(HomeRoute(session: session.copyWith(query: newValue)));
  }

  void append(String newValue) {
    final current = value.toWordList();
    final result = {...current.take(current.length), ...newValue.toWordList()};
    _value = '${result.join(' ')} ';
  }

  void replaceLast(String newValue) {
    final current = value.toWordList();
    final result = {
      if (current.isNotEmpty) ...current.take(current.length - 1),
      ...newValue.toWordList()
    };
    _value = '${result.join(' ')} ';
  }

  void appendTyped(String newValue) {
    value.endsWith(' ') ? append(newValue) : replaceLast(newValue);
  }

  void reset() {
    _value = initial;
    notifyListeners();
  }

  void open() {
    _open = true;
    notifyListeners();
  }

  void close() {
    _textTimer?.cancel();
    _open = false;
    notifyListeners();
  }

  void clear() {
    if (value.isEmpty) {
      reset();
      close();
    } else {
      textEditingController.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    textEditingController
      ..removeListener(notifyListeners)
      ..removeListener(_fetch);
    super.dispose();
  }
}
