enum ServerPayloadType {
  search,
  suggestion,
  post,
}

class ServerPayload {
  const ServerPayload({
    required this.result,
    required this.type,
  });

  final ServerScanResult result;
  final ServerPayloadType type;
}

class ServerScanResult {
  const ServerScanResult({
    this.origin = '',
    this.query = '',
  });

  final String origin;
  final String query;

  static const empty = ServerScanResult();
}
