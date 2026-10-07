// Контракт лога. Ключи с секретами реализация обязана отбрасывать.
abstract class AppLogger {
  void info(String message, {Map<String, Object?> fields = const {}});

  void warning(String message, {Map<String, Object?> fields = const {}});

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  });
}

const forbiddenLogKeys = {
  'password',
  'secret',
  'privatekey',
  'private_key',
  'passphrase',
  'token',
  'credential',
};
