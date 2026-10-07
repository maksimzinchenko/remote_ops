// Сохранённый сервер без секретов. Формат файла собирает infrastructure-кодек.
import 'authentication.dart';
import 'connection_options.dart';

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
    this.options = const ConnectionOptions(),
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final Authentication authentication;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ConnectionOptions options;

  ServerProfile copyWith({
    String? name,
    String? host,
    int? port,
    String? username,
    Authentication? authentication,
    DateTime? updatedAt,
    ConnectionOptions? options,
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
      options: options ?? this.options,
    );
  }
}
