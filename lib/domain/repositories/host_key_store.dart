// Локальный список доверенных host key.
import '../entities/stored_host_key.dart';

abstract class HostKeyStore {
  Future<StoredHostKey?> find(String host, int port);

  Future<void> save(StoredHostKey key);

  Future<void> delete(String host, int port);
}
