extension StringExt on String {
  String withHttpErrCode(num code) {
    return this + (code > 0 ? ' (HTTP $code)' : '');
  }
}
