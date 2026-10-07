// Сохранённый сервер без секретов. Модель допускает и другие способы входа.
import 'authentication.dart';

class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.authentication,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final Authentication authentication;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServerProfile copyWith({
    String? name,
    String? host,
    int? port,
    String? username,
    Authentication? authentication,
    DateTime? updatedAt,
  }) {
    return ServerProfile(
      id: id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authentication: authentication ?? this.authentication,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'username': username,
        'authentication': authentication.toJson(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  static ServerProfile fromJson(Map<String, Object?> json) {
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
      authentication: Authentication.fromJson(Map<String, Object?>.from(auth)),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')).toUtc(),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')).toUtc(),
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
