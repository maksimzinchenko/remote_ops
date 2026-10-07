// Перевод кодов ошибок и названий блоков. Команды из файла не переводятся.
import '../../core/errors/app_failure.dart';
import '../../domain/entities/command_script.dart';
import '../../l10n/generated/app_localizations.dart';

String failureText(AppLocalizations l10n, AppMessage code, [Map<String, String> params = const {}]) {
  return switch (code) {
    AppMessage.profileNotFound => l10n.failureProfileNotFound,
    AppMessage.passwordAuthOnly => l10n.failurePasswordAuthOnly,
    AppMessage.passwordMissing => l10n.failurePasswordMissing,
    AppMessage.connectionFailed => l10n.failureConnectionFailed,
    AppMessage.scriptNotFound => l10n.failureScriptNotFound,
    AppMessage.hostKeyRejected => l10n.failureHostKeyRejected,
    AppMessage.saveFailed => l10n.failureSaveFailed,
    AppMessage.requiredFields => l10n.failureRequiredFields,
    AppMessage.invalidPort => l10n.failureInvalidPort,
    AppMessage.passwordRequired => l10n.failurePasswordRequired,
    AppMessage.notConnected => l10n.failureNotConnected,
    AppMessage.timeout => l10n.failureTimeout,
    AppMessage.authFailed => l10n.failureAuthFailed,
    AppMessage.hostKeyDenied => l10n.failureHostKeyDenied,
    AppMessage.handshake => l10n.failureHandshake,
    AppMessage.disconnected => l10n.failureDisconnected,
    AppMessage.sshError => l10n.failureSshError,
    AppMessage.operationFailed => l10n.failureOperationFailed,
    AppMessage.dnsError => l10n.failureDns,
    AppMessage.connectionRefused => l10n.failureRefused,
    AppMessage.networkUnreachable => l10n.failureNetwork,
    AppMessage.unreachable => l10n.failureUnreachable,
    AppMessage.commandFailed => l10n.failureCommandFailed(params['name'] ?? '', params['code'] ?? '—'),
    AppMessage.scriptInterrupted => l10n.failureScriptInterrupted,
  };
}

String scriptTitle(AppLocalizations l10n, CommandScript script) {
  return switch (script.id) {
    'check_status' => l10n.scriptCheckStatusName,
    'identity' => l10n.scriptIdentityName,
    'processes' => l10n.scriptProcessesName,
    _ => script.name,
  };
}

String scriptDescription(AppLocalizations l10n, CommandScript script) {
  return switch (script.id) {
    'check_status' => l10n.scriptCheckStatusDescription,
    'identity' => l10n.scriptIdentityDescription,
    'processes' => l10n.scriptProcessesDescription,
    _ => script.description,
  };
}

String stepTitle(AppLocalizations l10n, String stepId, String fallback) {
  return switch (stepId) {
    'uptime' => l10n.stepUptime,
    'memory' => l10n.stepMemory,
    'disk' => l10n.stepDisk,
    'who' => l10n.stepWho,
    'ps' => l10n.stepPs,
    _ => fallback,
  };
}
