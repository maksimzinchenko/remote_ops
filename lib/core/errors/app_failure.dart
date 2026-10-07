// Код сообщения для перевода в UI. Слои ниже не знают язык пользователя.
abstract class AppMessage {
  static const profileNotFound = 'profileNotFound';
  static const passwordAuthOnly = 'passwordAuthOnly';
  static const passwordMissing = 'passwordMissing';
  static const connectionFailed = 'connectionFailed';
  static const scriptNotFound = 'scriptNotFound';
  static const hostKeyRejected = 'hostKeyRejected';
  static const saveFailed = 'saveFailed';
  static const requiredFields = 'requiredFields';
  static const invalidPort = 'invalidPort';
  static const passwordRequired = 'passwordRequired';
  static const notConnected = 'notConnected';
  static const timeout = 'timeout';
  static const authFailed = 'authFailed';
  static const hostKeyDenied = 'hostKeyDenied';
  static const handshake = 'handshake';
  static const disconnected = 'disconnected';
  static const sshError = 'sshError';
  static const operationFailed = 'operationFailed';
  static const dnsError = 'dnsError';
  static const connectionRefused = 'connectionRefused';
  static const networkUnreachable = 'networkUnreachable';
  static const unreachable = 'unreachable';
  static const commandFailed = 'commandFailed';
  static const scriptInterrupted = 'scriptInterrupted';
  static const cancelled = 'cancelled';
  static const keyInvalid = 'keyInvalid';
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
  cancelled,
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
  final String code;
  final Map<String, String> params;
  final String? debugDetail;

  @override
  String toString() => 'AppFailure($kind: $code)';
}
