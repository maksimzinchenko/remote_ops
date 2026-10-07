// Короткое SSH-соединение dartssh2. Его закрывает сценарий запуска блока.
import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/connections/remote_connection.dart';
import '../../domain/entities/execution_result.dart';
import '../../domain/entities/server_profile.dart';
import '../logging/debug_app_logger.dart';
import '../../core/logging/app_logger.dart';

typedef HostKeyCallback = Future<bool> Function({
  required String host,
  required int port,
  required String keyType,
  required String fingerprint,
});

class SshRemoteConnection implements RemoteConnection {
  SshRemoteConnection({
    required this.profile,
    required this.password,
    required this.onVerifyHostKey,
    AppLogger? logger,
    this.timeout = const Duration(seconds: 20),
  }) : _logger = logger ?? DebugAppLogger();

  final ServerProfile profile;
  final String password;
  final HostKeyCallback onVerifyHostKey;
  final Duration timeout;
  final AppLogger _logger;
  SSHClient? _client;

  @override
  bool get isConnected => _client != null;

  @override
  Future<void> connect() async {
    if (_client != null) {
      return;
    }
    SSHSocket? socket;
    SSHClient? client;
    try {
      socket = await SSHSocket.connect(profile.host, profile.port, timeout: timeout);
      client = SSHClient(
        socket,
        username: profile.username,
        onPasswordRequest: () => password,
        handshakeTimeout: timeout,
        authTimeout: timeout,
        onVerifyHostKey: (type, fingerprint) {
          final presented = String.fromCharCodes(fingerprint);
          return onVerifyHostKey(
            host: profile.host,
            port: profile.port,
            keyType: type,
            fingerprint: presented,
          );
        },
      );
      await client.authenticated.timeout(timeout);
      _client = client;
    } catch (error, stackTrace) {
      _logger.error(
        'ssh connect failed',
        error: error,
        stackTrace: stackTrace,
        fields: {'host': profile.host, 'port': profile.port},
      );
      await client?.close();
      socket?.destroy();
      throw mapSshError(error);
    }
  }

  @override
  Future<ExecutionResult> execute(String command) async {
    final client = _client;
    if (client == null) {
      throw const AppFailure(
        kind: AppFailureKind.disconnected,
        code: AppMessage.notConnected,
      );
    }
    final startedAt = DateTime.now().toUtc();
    try {
      final session = await client.execute(command);
      final stdout = StringBuffer();
      final stderr = StringBuffer();
      final stdoutDone = Completer<void>();
      final stderrDone = Completer<void>();
      session.stdout.listen(
        (chunk) => stdout.write(String.fromCharCodes(chunk)),
        onDone: () {
          if (!stdoutDone.isCompleted) stdoutDone.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!stdoutDone.isCompleted) stdoutDone.completeError(error, stackTrace);
        },
        cancelOnError: true,
      );
      session.stderr.listen(
        (chunk) => stderr.write(String.fromCharCodes(chunk)),
        onDone: () {
          if (!stderrDone.isCompleted) stderrDone.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!stderrDone.isCompleted) stderrDone.completeError(error, stackTrace);
        },
        cancelOnError: true,
      );
      final exitCode = await session.waitForExit();
      await Future.wait([stdoutDone.future, stderrDone.future]);
      return ExecutionResult(
        command: command,
        stdout: stdout.toString(),
        stderr: stderr.toString(),
        exitCode: exitCode,
        startedAt: startedAt,
        finishedAt: DateTime.now().toUtc(),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'ssh execute failed',
        error: error,
        stackTrace: stackTrace,
        fields: {'host': profile.host, 'port': profile.port},
      );
      if (error is AppFailure) {
        rethrow;
      }
      throw mapSshError(error);
    }
  }

/// Закрывает соединение этого запуска. Повторный вызов безопасен.
  @override
  Future<void> disconnect() async {
    final client = _client;
    _client = null;
    if (client != null) {
      await client.close();
    }
  }
}

AppFailure mapSshError(Object error) {
  if (error is AppFailure) {
    return error;
  }
  if (error is TimeoutException) {
    return const AppFailure(
      kind: AppFailureKind.timeout,
      code: AppMessage.timeout,
    );
  }
  if (error is SocketException) {
    return AppFailure(
      kind: AppFailureKind.unreachable,
      code: _socketCode(error),
      debugDetail: error.message,
    );
  }
  if (error is SSHAuthFailError || error is SSHAuthAbortError) {
    return AppFailure(
      kind: AppFailureKind.auth,
      code: AppMessage.authFailed,
      debugDetail: error.toString(),
    );
  }
  if (error is SSHHostkeyError) {
    return AppFailure(
      kind: AppFailureKind.hostKeyRejected,
      code: AppMessage.hostKeyDenied,
      debugDetail: error.message,
    );
  }
  if (error is SSHHandshakeError) {
    return AppFailure(
      kind: AppFailureKind.handshake,
      code: AppMessage.handshake,
      debugDetail: error.message,
    );
  }
  if (error is SSHDisconnectError) {
    return AppFailure(
      kind: AppFailureKind.disconnected,
      code: AppMessage.disconnected,
      debugDetail: error.message,
    );
  }
  if (error is SSHError) {
    return AppFailure(
      kind: AppFailureKind.unknown,
      code: AppMessage.sshError,
      debugDetail: error.toString(),
    );
  }
  return AppFailure(
    kind: AppFailureKind.unknown,
    code: AppMessage.operationFailed,
    debugDetail: error.toString(),
  );
}

AppMessage _socketCode(SocketException error) {
  final message = error.message.toLowerCase();
  if (message.contains('failed host lookup') || message.contains('name or service')) {
    return AppMessage.dnsError;
  }
  if (message.contains('connection refused')) {
    return AppMessage.connectionRefused;
  }
  if (message.contains('timed out')) {
    return AppMessage.timeout;
  }
  if (message.contains('network is unreachable')) {
    return AppMessage.networkUnreachable;
  }
  return AppMessage.unreachable;
}
