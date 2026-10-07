// Доверенный отпечаток host key для пары хост и порт.
import 'host_endpoint.dart';

class StoredHostKey {
  const StoredHostKey({
    required this.host,
    required this.port,
    required this.keyType,
    required this.fingerprint,
    required this.trustedAt,
    this.fingerprintAlgorithm = 'SHA256',
  });

  final String host;
  final int port;
  final String keyType;
  final String fingerprint;
  final String fingerprintAlgorithm;
  final DateTime trustedAt;

  String get endpoint => endpointKey(host, port);

  StoredHostKey copyWith({
    String? host,
    int? port,
    String? keyType,
    String? fingerprint,
    String? fingerprintAlgorithm,
    DateTime? trustedAt,
  }) {
    return StoredHostKey(
      host: host ?? this.host,
      port: port ?? this.port,
      keyType: keyType ?? this.keyType,
      fingerprint: fingerprint ?? this.fingerprint,
      fingerprintAlgorithm: fingerprintAlgorithm ?? this.fingerprintAlgorithm,
      trustedAt: trustedAt ?? this.trustedAt,
    );
  }
}
