import 'package:flutter_hooks/flutter_hooks.dart';

void Function() useMarkMayNeedRebuild() => use(const _MarkRebuildHook());

class _MarkRebuildHook extends Hook<void Function()> {
  const _MarkRebuildHook();

  @override
  _MarkRebuildState createState() => _MarkRebuildState();
}

class _MarkRebuildState extends HookState<void Function(), _MarkRebuildHook> {
  bool _mounted = true;

  void _call() {
    if (_mounted) markMayNeedRebuild();
  }

  @override
  void Function() build(_) => _call;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  String get debugLabel => 'useMarkMayNeedRebuild';
}
