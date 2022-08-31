class SphereException {
  const SphereException({required this.message});
  final String message;

  @override
  String toString() => 'SphereException: $message';
}
