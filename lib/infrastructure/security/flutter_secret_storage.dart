// SecretStorage через flutter_secure_storage, без своего формата секретов.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/secret_storage.dart';

class FlutterSecretStorage implements SecretStorage {
  FlutterSecretStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<String?> get(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
