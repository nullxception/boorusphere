import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

VoidCallback useRefresher() => use(const _RefreshHook());

class _RefreshHook extends Hook<VoidCallback> {
  const _RefreshHook();

  @override
  _RefresherHookState createState() => _RefresherHookState();
}

class _RefresherHookState extends HookState<VoidCallback, _RefreshHook> {
  bool _mounted = true;

  void _call() {
    if (_mounted) markMayNeedRebuild();
  }

  @override
  VoidCallback build(_) => _call;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  String get debugLabel => 'useRefresher';
}
