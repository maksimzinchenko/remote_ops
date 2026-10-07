// Хранение профилей без паролей.
import '../entities/server_profile.dart';

abstract class ServerRepository {
  Future<List<ServerProfile>> list();

  Future<ServerProfile?> findById(String id);

  Future<void> save(ServerProfile profile);

  Future<void> delete(String id);
}
