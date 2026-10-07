// Формат host_keys.json. Сущности domain его не знают.
import 'dart:convert';

import '../../domain/entities/host_endpoint.dart';
import '../../domain/entities/stored_host_key.dart';

class HostKeyStoreCodec {
  static const schemaVersion = 1;

  static List<StoredHostKey> decode(String source) {
    if (source.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(source);
    if (decoded is List) {
      return decoded.map((item) => fromJson(Map<String, Object?>.from(item as Map))).toList();
    }
    if (decoded is! Map) {
      throw const FormatException('host key store is not an object');
    }
    final version = decoded['schemaVersion'];
    if (version is! int || version > schemaVersion) {
      throw FormatException('unsupported host key store schema: $version');
    }
    final items = decoded['keys'];
    if (items is! List) {
      throw const FormatException('host key store has no keys');
    }
    return items.map((item) => fromJson(Map<String, Object?>.from(item as Map))).toList();
  }

  static String encode(List<StoredHostKey> keys) {
    return jsonEncode({
      'schemaVersion': schemaVersion,
      'keys': keys.map(toJson).toList(),
    });
  }

  static Map<String, Object?> toJson(StoredHostKey key) => {
        'host': normalizeHost(key.host),
        'port': key.port,
        'keyType': key.keyType,
        'fingerprint': key.fingerprint,
        'fingerprintAlgorithm': key.fingerprintAlgorithm,
        'trustedAt': key.trustedAt.toUtc().toIso8601String(),
      };

  static StoredHostKey fromJson(Map<String, Object?> json) {
    final host = json['host'];
    final keyType = json['keyType'];
    final fingerprint = json['fingerprint'];
    final trustedAt = json['trustedAt'];
    final port = json['port'];
    final algorithm = json['fingerprintAlgorithm'];
    if (host is! String || keyType is! String || fingerprint is! String || trustedAt is! String || port is! int) {
      throw const FormatException('invalid stored host key');
    }
    return StoredHostKey(
      host: normalizeHost(host),
      port: port,
      keyType: keyType,
      fingerprint: fingerprint,
      fingerprintAlgorithm: algorithm is String && algorithm.isNotEmpty ? algorithm : 'SHA256',
      trustedAt: DateTime.parse(trustedAt).toUtc(),
    );
  }
}
