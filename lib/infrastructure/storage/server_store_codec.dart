// Формат servers.json. Сущности domain его не знают.
import 'dart:convert';

import '../../domain/entities/authentication.dart';
import '../../domain/entities/connection_options.dart';
import '../../domain/entities/server_profile.dart';

class ServerStoreCodec {
  static const schemaVersion = 1;

  static List<ServerProfile> decode(String source) {
    if (source.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(source);
    if (decoded is List) {
      return decoded.map((item) => profileFromJson(Map<String, Object?>.from(item as Map))).toList();
    }
    if (decoded is! Map) {
      throw const FormatException('server store is not an object');
    }
    final version = decoded['schemaVersion'];
    if (version is! int || version > schemaVersion) {
      throw FormatException('unsupported server store schema: $version');
    }
    final items = decoded['profiles'];
    if (items is! List) {
      throw const FormatException('server store has no profiles');
    }
    return items.map((item) => profileFromJson(Map<String, Object?>.from(item as Map))).toList();
  }

  static String encode(List<ServerProfile> profiles) {
    return jsonEncode({
      'schemaVersion': schemaVersion,
      'profiles': profiles.map(profileToJson).toList(),
    });
  }

  static Map<String, Object?> profileToJson(ServerProfile profile) => {
        'id': profile.id,
        'name': profile.name,
        'host': profile.host,
        'port': profile.port,
        'username': profile.username,
        'authentication': authToJson(profile.authentication),
        'options': optionsToJson(profile.options),
        'createdAt': profile.createdAt.toUtc().toIso8601String(),
        'updatedAt': profile.updatedAt.toUtc().toIso8601String(),
      };

  static ServerProfile profileFromJson(Map<String, Object?> json) {
    final auth = json['authentication'];
    if (auth is! Map) {
      throw const FormatException('server profile has no authentication');
    }
    return ServerProfile(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      host: _requiredString(json, 'host'),
      port: _requiredPort(json['port']),
      username: _requiredString(json, 'username'),
      authentication: authFromJson(Map<String, Object?>.from(auth)),
      options: optionsFromJson(json['options']),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')).toUtc(),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')).toUtc(),
    );
  }

  static Map<String, Object?> authToJson(Authentication authentication) {
    return switch (authentication) {
      PasswordAuthentication(:final secretKey) => {
          'type': authentication.type,
          'secretKey': secretKey,
        },
      PrivateKeyAuthentication(:final privateKeySecretKey, :final passphraseSecretKey) => {
          'type': authentication.type,
          'privateKeySecretKey': privateKeySecretKey,
          'passphraseSecretKey': passphraseSecretKey,
        },
    };
  }

  static Authentication authFromJson(Map<String, Object?> json) {
    switch (json['type']) {
      case 'password':
        final secretKey = json['secretKey'];
        if (secretKey is! String || secretKey.isEmpty) {
          throw const FormatException('password authentication has no secretKey');
        }
        return PasswordAuthentication(secretKey: secretKey);
      case 'privateKey':
        final privateKeySecretKey = json['privateKeySecretKey'];
        if (privateKeySecretKey is! String || privateKeySecretKey.isEmpty) {
          throw const FormatException('private key authentication has no key reference');
        }
        final passphrase = json['passphraseSecretKey'];
        return PrivateKeyAuthentication(
          privateKeySecretKey: privateKeySecretKey,
          passphraseSecretKey: passphrase is String && passphrase.isNotEmpty ? passphrase : null,
        );
      default:
        throw FormatException('unsupported authentication type: ${json['type']}');
    }
  }

  static Map<String, Object?> optionsToJson(ConnectionOptions options) => {
        'connectTimeoutMs': options.connectTimeout.inMilliseconds,
        'preferredHostKeyAlgorithm': options.preferredHostKeyAlgorithm,
      };

  static ConnectionOptions optionsFromJson(Object? json) {
    if (json is! Map) {
      return const ConnectionOptions();
    }
    final timeout = json['connectTimeoutMs'];
    final algorithm = json['preferredHostKeyAlgorithm'];
    final milliseconds = timeout is int ? timeout : int.tryParse('$timeout');
    return ConnectionOptions(
      connectTimeout: milliseconds == null || milliseconds <= 0
          ? const Duration(seconds: 20)
          : Duration(milliseconds: milliseconds),
      preferredHostKeyAlgorithm: algorithm is String && algorithm.isNotEmpty ? algorithm : null,
    );
  }
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('server profile field $key is missing');
  }
  return value;
}

int _requiredPort(Object? value) {
  final port = value is int ? value : int.tryParse('$value');
  if (port == null || port < 1 || port > 65535) {
    throw const FormatException('server profile port is invalid');
  }
  return port;
}
