enum ServerPayloadType {
  search,
  suggestion,
  post,
}

class ServerPayload {
  const ServerPayload({
    required this.host,
    required this.query,
    required this.type,
  });

  final String host;
  final String query;
  final ServerPayloadType type;
}
