// Короткое SSH-соединение dartssh2. Его закрывает сценарий запуска блока.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

import '../../core/errors/app_failure.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/connections/execution_control.dart';
import '../../domain/connections/remote_connection.dart';
import '../../domain/connections/resolved_credentials.dart';
import '../../domain/entities/execution_result.dart';
import '../../domain/entities/server_profile.dart';
import '../logging/debug_app_logger.dart';

typedef HostKeyCallback = Future<bool> Function({
  required String host,
  required int port,
  required String keyType,
  required String fingerprint,
});

class SshRemoteConnection implements RemoteConnection {
  SshRemoteConnection({
    required this.profile,
    required this.credentials,
    required this.onVerifyHostKey,
    AppLogger? logger,
  }) : _logger = logger ?? DebugAppLogger();

  final ServerProfile profile;
  final ResolvedCredentials credentials;
  final HostKeyCallback onVerifyHostKey;
  final AppLogger _logger;
  SSHClient? _client;

  Duration get _timeout => profile.options.connectTimeout;

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
      socket = await SSHSocket.connect(profile.host, profile.port, timeout: _timeout);
      client = SSHClient(
        socket,
        username: profile.username,
        onPasswordRequest: _passwordRequest,
        identities: _identities(),
        handshakeTimeout: _timeout,
        authTimeout: _timeout,
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
      await client.authenticated.timeout(_timeout);
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

  String? _passwordRequest() {
    final credentials = this.credentials;
    if (credentials is PasswordCredentials) {
      return credentials.password;
    }
    return null;
  }

  List<SSHKeyPair>? _identities() {
    final credentials = this.credentials;
    if (credentials is! PrivateKeyCredentials) {
      return null;
    }
    try {
      return SSHKeyPair.fromPem(credentials.privateKeyPem, credentials.passphrase);
    } catch (error) {
      throw AppFailure(
        kind: AppFailureKind.auth,
        code: AppMessage.keyInvalid,
        debugDetail: redactSensitive(error.toString()),
      );
    }
  }

  @override
  Future<ExecutionResult> execute(
    String command, {
    ExecutionObserver? observer,
    RunCancellation? cancellation,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AppFailure(
        kind: AppFailureKind.disconnected,
        code: AppMessage.notConnected,
      );
    }
    if (cancellation?.isCancelled == true) {
      throw const AppFailure(kind: AppFailureKind.cancelled, code: AppMessage.cancelled);
    }
    final startedAt = DateTime.now().toUtc();
    try {
      final session = await client.execute(
        command,
        pty: const SSHPtyConfig(width: 120, height: 40),
        environment: const {'DEBIAN_FRONTEND': 'noninteractive'},
      );
      final stdout = StringBuffer();
      final stderr = StringBuffer();
      final stdoutDone = Completer<void>();
      final stderrDone = Completer<void>();
      session.stdout.listen(
        (chunk) => _append(stdout, chunk, OutputChannel.stdout, observer),
        onDone: () {
          if (!stdoutDone.isCompleted) stdoutDone.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!stdoutDone.isCompleted) stdoutDone.completeError(error, stackTrace);
        },
        cancelOnError: true,
      );
      session.stderr.listen(
        (chunk) => _append(stderr, chunk, OutputChannel.stderr, observer),
        onDone: () {
          if (!stderrDone.isCompleted) stderrDone.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!stderrDone.isCompleted) stderrDone.completeError(error, stackTrace);
        },
        cancelOnError: true,
      );
      final exitCode = await _waitForExit(session, cancellation);
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

  void _append(StringBuffer buffer, List<int> chunk, OutputChannel channel, ExecutionObserver? observer) {
    final text = utf8.decode(chunk, allowMalformed: true);
    buffer.write(text);
    observer?.onOutput(OutputChunk(channel: channel, text: text));
  }

  Future<int?> _waitForExit(SSHSession session, RunCancellation? cancellation) async {
    if (cancellation == null) {
      return session.waitForExit();
    }
    final cancel = cancellation.onCancel.then((_) {
      throw const AppFailure(kind: AppFailureKind.cancelled, code: AppMessage.cancelled);
    });
    try {
      return await Future.any([session.waitForExit(), cancel]);
    } on AppFailure {
      await disconnect();
      rethrow;
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
  final detail = redactSensitive(error.toString());
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
      debugDetail: detail,
    );
  }
  if (error is SSHHostkeyError) {
    return AppFailure(
      kind: AppFailureKind.hostKeyRejected,
      code: AppMessage.hostKeyDenied,
      debugDetail: redactSensitive(error.message),
    );
  }
  if (error is SSHHandshakeError) {
    return AppFailure(
      kind: AppFailureKind.handshake,
      code: AppMessage.handshake,
      debugDetail: redactSensitive(error.message),
    );
  }
  if (error is SSHDisconnectError) {
    return AppFailure(
      kind: AppFailureKind.disconnected,
      code: AppMessage.disconnected,
      debugDetail: redactSensitive(error.message),
    );
  }
  if (error is SSHError) {
    return AppFailure(
      kind: AppFailureKind.unknown,
      code: AppMessage.sshError,
      debugDetail: detail,
    );
  }
  return AppFailure(
    kind: AppFailureKind.unknown,
    code: AppMessage.operationFailed,
    debugDetail: detail,
  );
}

String _socketCode(SocketException error) {
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

String redactSensitive(String value) {
  if (value.contains('PRIVATE KEY') || value.contains('passphrase') || value.contains('password=')) {
    return '[redacted]';
  }
  return value;
}
