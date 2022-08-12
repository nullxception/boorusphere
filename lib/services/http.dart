import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final httpProvider = Provider((ref) => SphereHttpClient(ref, http.Client()));

class SphereHttpClient extends http.BaseClient {
  SphereHttpClient(this.ref, this._mainClient);

  final Ref ref;

  final http.Client _mainClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Referer'] = request.url.toString();
    return _mainClient.send(request);
  }
}
