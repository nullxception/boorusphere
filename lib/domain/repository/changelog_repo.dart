abstract interface class ChangelogRepo {
  Future<String> get();
  Future<String> fetch();
}
