import 'dart:io';

class BaseHttpClient implements HttpClient {
  BaseHttpClient(this.client);
  final HttpClient client;

  @override
  bool get autoUncompress {
    return client.autoUncompress;
  }

  @override
  set autoUncompress(bool value) {
    client.autoUncompress = value;
  }

  @override
  Duration get idleTimeout {
    return client.idleTimeout;
  }

  @override
  set idleTimeout(Duration value) {
    client.idleTimeout = value;
  }

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {
    client.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  void close({bool force = false}) {
    client.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return client.delete(host, port, path);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return client.deleteUrl(url);
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return client.get(host, port, path);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return client.getUrl(url.replace(path: url.path));
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return client.head(host, port, path);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return client.headUrl(url);
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return client.open(method, host, port, path);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return client.openUrl(method, url);
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return client.patch(host, port, path);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return client.patchUrl(url);
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return client.post(host, port, path);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return client.postUrl(url);
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return client.put(host, port, path);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return client.putUrl(url);
  }

  @override
  Duration? connectionTimeout;

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  set authenticate(
      Future<bool> Function(Uri url, String scheme, String? realm)? f) {
    client.authenticate = f;
  }

  @override
  set authenticateProxy(
      Future<bool> Function(
              String host, int port, String scheme, String? realm)?
          f) {
    client.authenticateProxy = f;
  }

  @override
  set badCertificateCallback(
      bool Function(X509Certificate cert, String host, int port)? callback) {
    client.badCertificateCallback = callback;
  }

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String? proxyHost, int? proxyPort)?
          f) {
    client.connectionFactory = f;
  }

  @override
  set findProxy(String Function(Uri url)? f) {
    client.findProxy = f;
  }

  @override
  set keyLog(Function(String line)? callback) {
    client.keyLog = callback;
  }
}
