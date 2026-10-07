import '../entities/server_profile.dart';
import 'remote_connection.dart';

/// Создаёт соединение, которое живёт только внутри одного запуска.
abstract class RemoteConnectionFactory {
  Future<RemoteConnection> open({
    required ServerProfile profile,
    required String password,
  });
}

