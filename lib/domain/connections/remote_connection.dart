import '../entities/execution_result.dart';

/// Короткое удалённое соединение на один запуск блока команд.
/// Постоянных сессий и пула нет: вызывающий обязан закрыть его после выполнения.
abstract class RemoteConnection {
  Future<void> connect();

  Future<ExecutionResult> execute(String command);

  Future<void> disconnect();

  bool get isConnected;
}

