class SphereException implements Exception {
  SphereException({required this.message});
  final String message;

  @override
  String toString() => 'SphereException: $message';
}
