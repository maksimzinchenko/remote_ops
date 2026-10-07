// Перевод кодов ошибок и названий блоков. Неизвестный код не требует нового экрана.
import '../../core/errors/app_failure.dart';
import '../../domain/entities/command_script.dart';
import '../../l10n/generated/app_localizations.dart';

typedef _Text = String Function(AppLocalizations l10n, Map<String, String> params);

String failureText(AppLocalizations l10n, String code, [Map<String, String> params = const {}]) {
  final known = _failures[code];
  if (known == null) {
    return l10n.failureOperationFailed;
  }
  return known(l10n, params);
}

String scriptTitle(AppLocalizations l10n, CommandScript script) {
  return _catalogText(l10n, script.titleKey) ?? _catalogText(l10n, script.id) ?? script.name;
}

String scriptDescription(AppLocalizations l10n, CommandScript script) {
  return _catalogText(l10n, script.descriptionKey) ??
      _catalogText(l10n, '${script.id}.description') ??
      script.description;
}

String stepTitle(AppLocalizations l10n, String stepId, String fallback) {
  return _catalogText(l10n, stepId) ?? fallback;
}

String? _catalogText(AppLocalizations l10n, String? key) {
  if (key == null) return null;
  return _catalog[key]?.call(l10n);
}

final _catalog = <String, String Function(AppLocalizations)>{
  'scriptCheckStatusName': (l10n) => l10n.scriptCheckStatusName,
  'check_status': (l10n) => l10n.scriptCheckStatusName,
  'scriptCheckStatusDescription': (l10n) => l10n.scriptCheckStatusDescription,
  'check_status.description': (l10n) => l10n.scriptCheckStatusDescription,
  'scriptIdentityName': (l10n) => l10n.scriptIdentityName,
  'identity': (l10n) => l10n.scriptIdentityName,
  'scriptIdentityDescription': (l10n) => l10n.scriptIdentityDescription,
  'identity.description': (l10n) => l10n.scriptIdentityDescription,
  'scriptProcessesName': (l10n) => l10n.scriptProcessesName,
  'processes': (l10n) => l10n.scriptProcessesName,
  'scriptProcessesDescription': (l10n) => l10n.scriptProcessesDescription,
  'processes.description': (l10n) => l10n.scriptProcessesDescription,
  'stepUptime': (l10n) => l10n.stepUptime,
  'uptime': (l10n) => l10n.stepUptime,
  'stepMemory': (l10n) => l10n.stepMemory,
  'memory': (l10n) => l10n.stepMemory,
  'stepDisk': (l10n) => l10n.stepDisk,
  'disk': (l10n) => l10n.stepDisk,
  'stepWho': (l10n) => l10n.stepWho,
  'who': (l10n) => l10n.stepWho,
  'stepPs': (l10n) => l10n.stepPs,
  'ps': (l10n) => l10n.stepPs,
  'scriptInstallDockerName': (l10n) => l10n.scriptInstallDockerName,
  'install_docker': (l10n) => l10n.scriptInstallDockerName,
  'scriptInstallDockerDescription': (l10n) => l10n.scriptInstallDockerDescription,
  'install_docker.description': (l10n) => l10n.scriptInstallDockerDescription,
  'stepInstallDocker': (l10n) => l10n.stepInstallDocker,
  'scriptUninstallDockerName': (l10n) => l10n.scriptUninstallDockerName,
  'uninstall_docker': (l10n) => l10n.scriptUninstallDockerName,
  'scriptUninstallDockerDescription': (l10n) => l10n.scriptUninstallDockerDescription,
  'uninstall_docker.description': (l10n) => l10n.scriptUninstallDockerDescription,
  'stepUninstallDocker': (l10n) => l10n.stepUninstallDocker,
};

String? remoteOpsStatus(String stdout) {
  for (final line in stdout.split('\n')) {
    const prefix = 'REMOTE_OPS_STATUS=';
    if (line.startsWith(prefix)) {
      final code = line.substring(prefix.length).trim();
      return code.isEmpty ? null : code;
    }
  }
  return null;
}

String? commandStatusText(AppLocalizations l10n, String? code) {
  return switch (code) {
    'installed' => l10n.dockerStatusInstalled,
    'already_installed' => l10n.dockerStatusAlready,
    'install_failed' => l10n.dockerStatusFailed,
    'need_root' => l10n.dockerStatusNeedRoot,
    'unsupported_os' => l10n.dockerStatusUnsupported,
    'installed_no_daemon' => l10n.dockerStatusNoDaemon,
    'network_error' => l10n.dockerStatusNetwork,
    'removed' => l10n.dockerStatusRemoved,
    'not_installed' => l10n.dockerStatusNotInstalled,
    'remove_failed' => l10n.dockerStatusRemoveFailed,
    'remove_need_root' => l10n.dockerStatusRemoveNeedRoot,
    'remove_unsupported_os' => l10n.dockerStatusRemoveUnsupported,
    _ => null,
  };
}

final _failures = <String, _Text>{
  AppMessage.profileNotFound: (l10n, _) => l10n.failureProfileNotFound,
  AppMessage.passwordAuthOnly: (l10n, _) => l10n.failurePasswordAuthOnly,
  AppMessage.passwordMissing: (l10n, _) => l10n.failurePasswordMissing,
  AppMessage.connectionFailed: (l10n, _) => l10n.failureConnectionFailed,
  AppMessage.scriptNotFound: (l10n, _) => l10n.failureScriptNotFound,
  AppMessage.hostKeyRejected: (l10n, _) => l10n.failureHostKeyRejected,
  AppMessage.saveFailed: (l10n, _) => l10n.failureSaveFailed,
  AppMessage.requiredFields: (l10n, _) => l10n.failureRequiredFields,
  AppMessage.invalidPort: (l10n, _) => l10n.failureInvalidPort,
  AppMessage.passwordRequired: (l10n, _) => l10n.failurePasswordRequired,
  AppMessage.notConnected: (l10n, _) => l10n.failureNotConnected,
  AppMessage.timeout: (l10n, _) => l10n.failureTimeout,
  AppMessage.authFailed: (l10n, _) => l10n.failureAuthFailed,
  AppMessage.hostKeyDenied: (l10n, _) => l10n.failureHostKeyDenied,
  AppMessage.handshake: (l10n, _) => l10n.failureHandshake,
  AppMessage.disconnected: (l10n, _) => l10n.failureDisconnected,
  AppMessage.sshError: (l10n, _) => l10n.failureSshError,
  AppMessage.operationFailed: (l10n, _) => l10n.failureOperationFailed,
  AppMessage.dnsError: (l10n, _) => l10n.failureDns,
  AppMessage.connectionRefused: (l10n, _) => l10n.failureRefused,
  AppMessage.networkUnreachable: (l10n, _) => l10n.failureNetwork,
  AppMessage.unreachable: (l10n, _) => l10n.failureUnreachable,
  AppMessage.commandFailed: (l10n, params) =>
      l10n.failureCommandFailed(params['name'] ?? '', params['code'] ?? '—'),
  AppMessage.scriptInterrupted: (l10n, _) => l10n.failureScriptInterrupted,
  AppMessage.cancelled: (l10n, _) => l10n.statusCancelled,
  AppMessage.keyInvalid: (l10n, _) => l10n.failureAuthFailed,
};
