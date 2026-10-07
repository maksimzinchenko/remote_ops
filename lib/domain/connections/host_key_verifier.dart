// Проверка host key. Инфраструктура зависит от этого порта, не от сценария UI.
abstract class HostKeyVerifier {
  Future<bool> verify({
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  });
}
