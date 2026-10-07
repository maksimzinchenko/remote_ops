// Доверенный отпечаток host key для пары хост и порт.
class StoredHostKey {
  const StoredHostKey({
    required this.host,
    required this.port,
    required this.keyType,
    required this.fingerprint,
    required this.trustedAt,
  });

  final String host;
  final int port;
  final String keyType;
  final String fingerprint;
  final DateTime trustedAt;

  String get endpoint => '$host:$port';

  Map<String, Object?> toJson() => {
        'host': host,
        'port': port,
        'keyType': keyType,
        'fingerprint': fingerprint,
        'trustedAt': trustedAt.toUtc().toIso8601String(),
      };

  static StoredHostKey fromJson(Map<String, Object?> json) {
    final host = json['host'];
    final keyType = json['keyType'];
    final fingerprint = json['fingerprint'];
    final port = json['port'];
    final trustedAt = json['trustedAt'];
    if (host is! String ||
        keyType is! String ||
        fingerprint is! String ||
        trustedAt is! String ||
        port is! int) {
      throw const FormatException('invalid stored host key');
    }
    return StoredHostKey(
      host: host,
      port: port,
      keyType: keyType,
      fingerprint: fingerprint,
      trustedAt: DateTime.parse(trustedAt).toUtc(),
    );
  }
}
