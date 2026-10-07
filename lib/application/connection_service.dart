// Одноразовое подключение: проверка логина или один блок команд на одном сервере.
import '../core/errors/app_failure.dart';
import '../core/logging/app_logger.dart';
import '../domain/connections/remote_connection.dart';
import '../domain/connections/remote_connection_factory.dart';
import '../domain/entities/authentication.dart';
import '../domain/entities/server_profile.dart';
import '../domain/entities/execution_result.dart';
import '../domain/repositories/script_catalog.dart';
import '../domain/repositories/secret_storage.dart';
import '../domain/repositories/server_repository.dart';
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
    final password = await _requirePassword(profile);
    _logger.info(
      'connecting',
      fields: {'host': profile.host, 'port': profile.port, 'username': profile.username},
    );
    try {
      final connection = await _connections.open(profile: profile, password: password);
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
      connection = await _connections.open(profile: profile, password: draft.password);
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

  Future<String> _requirePassword(ServerProfile profile) async {
    final auth = profile.authentication;
    if (auth is! PasswordAuthentication) {
      throw const AppFailure(
        kind: AppFailureKind.validation,
        code: AppMessage.passwordAuthOnly,
      );
    }
    final password = await _secrets.get(auth.secretKey);
    if (password == null || password.isEmpty) {
      throw const AppFailure(
        kind: AppFailureKind.storage,
        code: AppMessage.passwordMissing,
      );
    }
    return password;
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
/// Параллельный запуск на нескольких серверах позже можно собрать из таких же
/// независимых запросов, каждый со своим коротким соединением.
class CommandBlockRequest {
  const CommandBlockRequest({required this.profileId, required this.scriptId});

  final String profileId;
  final String scriptId;
}

class ScriptExecutionService {
  ScriptExecutionService({
    required ConnectionService connections,
    required ScriptCatalog scripts,
    required AppLogger logger,
  })  : _connections = connections,
        _scripts = scripts,
        _logger = logger;

  final ConnectionService _connections;
  final ScriptCatalog _scripts;
  final AppLogger _logger;

  /// Подключается к одному серверу, выполняет шаги по порядку и ждёт завершения.
  /// Соединение не остаётся открытым после возврата.
  Future<ScriptRun> run({
    required CommandBlockRequest request,
    void Function(ScriptRun progress)? onProgress,
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
      AppMessage? failureCode,
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

    publish(ScriptRunStatus.running);
    try {
      connection = await _connections.connect(request.profileId);
      for (final step in script.steps) {
        _logger.info('executing command', fields: {'commandName': step.name});
        final result = await connection.execute(step.command);
        steps.add(
          ScriptStepResult(stepId: step.id, stepName: step.name, result: result),
        );
        _logger.info(
          'command finished',
          fields: {
            'commandName': step.name,
            'exitCode': result.exitCode ?? -1,
            'durationMs': result.duration.inMilliseconds,
          },
        );
        if (!result.success && script.stopOnError) {
          return publish(
            ScriptRunStatus.failed,
            failureCode: AppMessage.commandFailed,
            failureParams: {
              'name': step.name,
              'code': '${result.exitCode ?? '—'}',
            },
          );
        }
        publish(ScriptRunStatus.running);
      }
      return publish(ScriptRunStatus.completed);
    } on AppFailure catch (failure) {
      return publish(ScriptRunStatus.failed, failureCode: failure.code, failureParams: failure.params);
    } catch (error, stackTrace) {
      _logger.error('script failed', error: error, stackTrace: stackTrace);
      return publish(ScriptRunStatus.failed, failureCode: AppMessage.scriptInterrupted);
    } finally {
      await connection?.disconnect();
    }
  }
}
