// Защищённое хранилище секретов конкретной ОС.
abstract class SecretStorage {
  Future<void> save(String key, String value);

  Future<String?> get(String key);

  Future<void> delete(String key);
}
