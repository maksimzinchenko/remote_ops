// Код сообщения для перевода в UI. Слои ниже не знают язык пользователя.
enum AppMessage {
  profileNotFound,
  passwordAuthOnly,
  passwordMissing,
  connectionFailed,
  scriptNotFound,
  hostKeyRejected,
  saveFailed,
  requiredFields,
  invalidPort,
  passwordRequired,
  notConnected,
  timeout,
  authFailed,
  hostKeyDenied,
  handshake,
  disconnected,
  sshError,
  operationFailed,
  dnsError,
  connectionRefused,
  networkUnreachable,
  unreachable,
  commandFailed,
  scriptInterrupted,
}

enum AppFailureKind {
  validation,
  notFound,
  auth,
  hostKeyRejected,
  unreachable,
  timeout,
  handshake,
  disconnected,
  command,
  storage,
  unknown,
}

/// Ошибка для пользователя. Текст выбирается по [code] на текущем языке.
class AppFailure implements Exception {
  const AppFailure({
    required this.kind,
    required this.code,
    this.params = const {},
    this.debugDetail,
  });

  final AppFailureKind kind;
  final AppMessage code;
  final Map<String, String> params;
  final String? debugDetail;

  @override
  String toString() => 'AppFailure($kind: $code)';
}
