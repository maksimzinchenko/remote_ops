// Одноразовое подключение: проверка логина или один блок команд на одном сервере.
import '../core/errors/app_failure.dart';
import '../core/logging/app_logger.dart';
import '../domain/connections/execution_control.dart';
import '../domain/connections/remote_connection.dart';
import '../domain/connections/remote_connection_factory.dart';
import '../domain/connections/resolved_credentials.dart';
import '../domain/entities/authentication.dart';
import '../domain/entities/execution_result.dart';
import '../domain/entities/server_profile.dart';
import '../domain/repositories/execution_journal.dart';
import '../domain/repositories/parameter_value_store.dart';
import '../domain/repositories/script_catalog.dart';
import 'command_binder.dart';
import '../domain/repositories/secret_storage.dart';
import '../domain/repositories/server_repository.dart';
import 'noop_execution_journal.dart';
import 'server_profile_service.dart';

class ConnectionService {
  ConnectionService({
    required ServerRepository servers,
    required SecretStorage secrets,
    required RemoteConnectionFactory connections,
    required AppLogger logger,
  })  : _servers = servers,
        _secrets = secrets,
        _connections = connections,
        _logger = logger;

  final ServerRepository _servers;
  final SecretStorage _secrets;
  final RemoteConnectionFactory _connections;
  final AppLogger _logger;

  Future<RemoteConnection> connect(String profileId) async {
    final profile = await _requireProfile(profileId);
    final credentials = await _requireCredentials(profile);
    _logger.info(
      'connecting',
      fields: {'host': profile.host, 'port': profile.port, 'username': profile.username},
    );
    try {
      final connection = await _connections.open(profile: profile, credentials: credentials);
      await connection.connect();
      _logger.info('connected', fields: {'host': profile.host, 'port': profile.port});
      return connection;
    } catch (error, stackTrace) {
      throw _asFailure(error, stackTrace, profile);
    }
  }

  /// Проверка логина без сохранения профиля. Соединение закрывается до возврата.
  Future<void> testDraft(ServerDraft draft) async {
    final profile = ServerProfile(
      id: 'draft',
      name: draft.name.trim(),
      host: draft.host.trim(),
      port: draft.port,
      username: draft.username.trim(),
      authentication: const PasswordAuthentication(secretKey: 'draft'),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    _logger.info('testing connection', fields: {'host': profile.host, 'port': profile.port});
    RemoteConnection? connection;
    try {
      connection = await _connections.open(
        profile: profile,
        credentials: PasswordCredentials(draft.password),
      );
      await connection.connect();
    } catch (error, stackTrace) {
      throw _asFailure(error, stackTrace, profile);
    } finally {
      await connection?.disconnect();
    }
  }

  Future<ServerProfile> _requireProfile(String profileId) async {
    final profile = await _servers.findById(profileId);
    if (profile == null) {
      throw const AppFailure(
        kind: AppFailureKind.notFound,
        code: AppMessage.profileNotFound,
      );
    }
    return profile;
  }

  Future<ResolvedCredentials> _requireCredentials(ServerProfile profile) async {
    final auth = profile.authentication;
    if (auth is PasswordAuthentication) {
      final password = await _secrets.get(auth.secretKey);
      if (password == null || password.isEmpty) {
        throw const AppFailure(
          kind: AppFailureKind.storage,
          code: AppMessage.passwordMissing,
        );
      }
      return PasswordCredentials(password);
    }
    if (auth is PrivateKeyAuthentication) {
      final privateKey = await _secrets.get(auth.privateKeySecretKey);
      if (privateKey == null || privateKey.isEmpty) {
        throw const AppFailure(
          kind: AppFailureKind.storage,
          code: AppMessage.passwordMissing,
        );
      }
      final passphraseKey = auth.passphraseSecretKey;
      final passphrase = passphraseKey == null ? null : await _secrets.get(passphraseKey);
      return PrivateKeyCredentials(privateKeyPem: privateKey, passphrase: passphrase);
    }
    throw const AppFailure(
      kind: AppFailureKind.validation,
      code: AppMessage.passwordAuthOnly,
    );
  }

  AppFailure _asFailure(Object error, StackTrace stackTrace, ServerProfile profile) {
    if (error is AppFailure) {
      return error;
    }
    _logger.error(
      'connection failed',
      error: error,
      stackTrace: stackTrace,
      fields: {'host': profile.host, 'port': profile.port},
    );
    return AppFailure(
      kind: AppFailureKind.unknown,
      code: AppMessage.connectionFailed,
      debugDetail: error.toString(),
    );
  }
}

/// Запуск блока команд на одном сервере.
/// Соединение открывается здесь и закрывается до возврата: UI его не держит.
class CommandBlockRequest {
  const CommandBlockRequest({required this.profileId, required this.scriptId});

  final String profileId;
  final String scriptId;
}

class ScriptExecutionService {
  ScriptExecutionService({
    required ConnectionService connections,
    required ScriptCatalog scripts,
    required ParameterValueStore parameters,
    required AppLogger logger,
    ExecutionJournal? journal,
  })  : _connections = connections,
        _scripts = scripts,
        _parameters = parameters,
        _logger = logger,
        _journal = journal ?? const NoOpExecutionJournal();

  final ConnectionService _connections;
  final ScriptCatalog _scripts;
  final ParameterValueStore _parameters;
  final AppLogger _logger;
  final ExecutionJournal _journal;
  final _binder = const CommandBinder();

  /// Подключается к одному серверу, выполняет шаги по порядку и ждёт завершения.
  /// Соединение не остаётся открытым после возврата.
  Future<ScriptRun> run({
    required CommandBlockRequest request,
    void Function(ScriptRun progress)? onProgress,
    void Function(String stepId, OutputChunk chunk)? onOutput,
    void Function(String stepId, String stepName)? onStep,
    RunCancellation? cancellation,
  }) async {
    final script = await _scripts.findById(request.scriptId);
    if (script == null) {
      throw const AppFailure(
        kind: AppFailureKind.notFound,
        code: AppMessage.scriptNotFound,
      );
    }
    final steps = <ScriptStepResult>[];
    RemoteConnection? connection;
    ScriptRun publish(
      ScriptRunStatus status, {
      String? failureCode,
      Map<String, String> failureParams = const {},
    }) {
      final run = ScriptRun(
        scriptId: script.id,
        scriptName: script.name,
        status: status,
        steps: List.unmodifiable(steps),
        failureCode: failureCode,
        failureParams: failureParams,
      );
      onProgress?.call(run);
      return run;
    }

    final stored = await _parameters.read(request.profileId, script.id);
    if (_binder.missing(script.parameters, stored).isNotEmpty) {
      throw const AppFailure(
        kind: AppFailureKind.validation,
        code: AppMessage.parametersRequired,
      );
    }
    publish(ScriptRunStatus.running);
    try {
      if (cancellation?.isCancelled == true) {
        return await _finish(publish(ScriptRunStatus.cancelled, failureCode: AppMessage.cancelled));
      }
      connection = await _connections.connect(request.profileId);
      for (final step in script.steps) {
        if (cancellation?.isCancelled == true) {
          return await _finish(publish(ScriptRunStatus.cancelled, failureCode: AppMessage.cancelled));
        }
        _logger.info('executing command', fields: {'stepId': step.id});
        onStep?.call(step.id, step.name);
        final command = _binder.bind(step, script.parameters, stored);
        final result = await connection.execute(
          command,
          cancellation: cancellation,
          observer: onOutput == null
              ? null
              : _StepObserver((chunk) => onOutput(step.id, chunk)),
        );
        steps.add(
          ScriptStepResult(stepId: step.id, stepName: step.name, result: result),
        );
        _logger.info(
          'command finished',
          fields: {
            'stepId': step.id,
            'exitCode': result.exitCode ?? -1,
            'durationMs': result.duration.inMilliseconds,
          },
        );
        if (!result.success && script.stopOnError) {
          return await _finish(
            publish(
              ScriptRunStatus.failed,
              failureCode: AppMessage.commandFailed,
              failureParams: {
                'name': step.name,
                'code': '${result.exitCode ?? '—'}',
              },
            ),
          );
        }
        publish(ScriptRunStatus.running);
      }
      return await _finish(publish(ScriptRunStatus.completed));
    } on AppFailure catch (failure) {
      final cancelled = failure.code == AppMessage.cancelled || cancellation?.isCancelled == true;
      return await _finish(
        publish(
          cancelled ? ScriptRunStatus.cancelled : ScriptRunStatus.failed,
          failureCode: cancelled ? AppMessage.cancelled : failure.code,
          failureParams: failure.params,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error('script failed', error: error, stackTrace: stackTrace);
      return await _finish(publish(ScriptRunStatus.failed, failureCode: AppMessage.scriptInterrupted));
    } finally {
      await connection?.disconnect();
    }
  }

  Future<ScriptRun> _finish(ScriptRun run) async {
    await _journal.record(run);
    return run;
  }
}

class _StepObserver implements ExecutionObserver {
  _StepObserver(this._onOutput);

  final void Function(OutputChunk chunk) _onOutput;

  @override
  void onOutput(OutputChunk chunk) => _onOutput(chunk);
}
