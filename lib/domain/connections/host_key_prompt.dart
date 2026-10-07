// Вопрос пользователю: доверять новому или изменившемуся ключу.
abstract class HostKeyPrompt {
  Future<bool> confirmUnknown({
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  });

  Future<bool> confirmChanged({
    required String host,
    required int port,
    required String keyType,
    required String storedFingerprint,
    required String presentedFingerprint,
  });
}
