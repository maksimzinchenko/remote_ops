// Опции соединения. Jump host и выбор алгоритма здесь только как порт, SSH их не применяет.
class ConnectionOptions {
  const ConnectionOptions({
    this.connectTimeout = const Duration(seconds: 20),
    this.preferredHostKeyAlgorithm,
  });

  final Duration connectTimeout;

  /// Зарезервировано. Проверка host key пока не фильтрует алгоритм.
  final String? preferredHostKeyAlgorithm;

  ConnectionOptions copyWith({
    Duration? connectTimeout,
    String? preferredHostKeyAlgorithm,
  }) {
    return ConnectionOptions(
      connectTimeout: connectTimeout ?? this.connectTimeout,
      preferredHostKeyAlgorithm: preferredHostKeyAlgorithm ?? this.preferredHostKeyAlgorithm,
    );
  }
}
